pragma Ada_2022;
pragma Extensions_Allowed (On);

with Ada.Unchecked_Conversion;

----------------------------
-- Read_Constant_Pool_Map --
----------------------------

separate (File_Formats.Java.Class)
procedure Read_Constant_Pool_Map
  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
   Item   : out Constant_Pool_Maps.Map)
is
   Constant_Pool_Count, Constant_Pool_Position : Constant_Pool_Index;
   Read_Tag                                    : Constant_Pool_Entry_Tag;

   type Incomplete_Entry (Tag : Constant_Pool_Entry_Tag) is record
      case Tag is
         when CLASS =>
            Qualified_Name_Ref : Constant_Pool_Index;

         when STRING =>
            String_Ref : Constant_Pool_Index;

         when FIELD_REFERENCE
               | METHOD_REFERENCE
               | INTERFACE_METHOD_REFERENCE =>
            Class_Ref         : Constant_Pool_Index;
            Name_And_Type_Ref : Constant_Pool_Index;

         when NAME_AND_TYPE =>
            Name_Ref, Descriptor_Ref : Constant_Pool_Index;

         when others =>
            null;
      end case;
   end record;

   package Incomplete_Pool_Maps is new
     Ada.Containers.Indefinite_Ordered_Maps
       (Constant_Pool_Index,
        Incomplete_Entry);

   Incomplete_Map : Incomplete_Pool_Maps.Map;

   function u4_To_Float is new
     Ada.Unchecked_Conversion (u4.Big_Endian, Standard.Float);
   function u8_To_Double is new
     Ada.Unchecked_Conversion (u8.Big_Endian, Standard.Long_Float);

   procedure Handle_Incomplete_Entry (Index : Constant_Pool_Index) is
   begin
      if not Incomplete_Map.Contains (Index) then
         return;
      end if;
      declare
         Incomplete : constant Incomplete_Entry :=
           Incomplete_Map.Element (Index);
      begin
         case Incomplete.Tag is
            when STRING =>
               Item.Include
                 (Index,
                  Constant_Pool_Entry'
                    (STRING,
                       new Utf_8_Constant_Pool_Entry'
                         (Utf_8_Constant_Pool_Entry
                            (Item.Element (Incomplete.String_Ref)))));

            when CLASS =>
               Item.Include
                 (Index,
                  Constant_Pool_Entry'
                    (CLASS,
                       new Utf_8_Constant_Pool_Entry'
                         (Utf_8_Constant_Pool_Entry
                            (Item.Element (Incomplete.Qualified_Name_Ref)))));

            when NAME_AND_TYPE =>
               Item.Include
                 (Index,
                  Constant_Pool_Entry'
                    (NAME_AND_TYPE,
                       new Utf_8_Constant_Pool_Entry'
                         (Utf_8_Constant_Pool_Entry
                            (Item.Element (Incomplete.Name_Ref))),
                       new Utf_8_Constant_Pool_Entry'
                         (Utf_8_Constant_Pool_Entry
                            (Item.Element (Incomplete.Descriptor_Ref)))));

            when FIELD_REFERENCE
               | METHOD_REFERENCE
               | INTERFACE_METHOD_REFERENCE
            =>
               Handle_Incomplete_Entry (Incomplete.Class_Ref);
               Handle_Incomplete_Entry (Incomplete.Name_And_Type_Ref);
               declare
                  Class         : constant Class_Constant_Pool_Entry :=
                    Class_Constant_Pool_Entry
                      (Item.Element (Incomplete.Class_Ref));
                  Name_And_Type : constant Name_And_Type_Constant_Pool_Entry :=
                    Name_And_Type_Constant_Pool_Entry
                      (Item.Element (Incomplete.Name_And_Type_Ref));
               begin
                  case Incomplete.Tag is
                     when FIELD_REFERENCE =>
                        Item.Include
                          (Index,
                           Constant_Pool_Entry'
                             (FIELD_REFERENCE,
                              new Class_Constant_Pool_Entry'(Class),
                                new Name_And_Type_Constant_Pool_Entry'
                                  (Name_And_Type)));

                     when METHOD_REFERENCE =>
                        Item.Include
                          (Index,
                           Constant_Pool_Entry'
                             (METHOD_REFERENCE,
                              new Class_Constant_Pool_Entry'(Class),
                                new Name_And_Type_Constant_Pool_Entry'
                                  (Name_And_Type)));

                     when INTERFACE_METHOD_REFERENCE =>
                        Item.Include
                          (Index,
                           Constant_Pool_Entry'
                             (INTERFACE_METHOD_REFERENCE,
                              new Class_Constant_Pool_Entry'(Class),
                                new Name_And_Type_Constant_Pool_Entry'
                                  (Name_And_Type)));

                     when others =>
                        raise Constraint_Error;
                  end case;
               end;

            when others =>
               raise Constraint_Error;
         end case;
      end;
   end Handle_Incomplete_Entry;
begin
   i2.Big_Endian'Read (Stream, Constant_Pool_Count);
   Constant_Pool_Count := @ - 1;
   Constant_Pool_Position := 1;
   loop
      Constant_Pool_Entry_Tag'Read (Stream, Read_Tag);
      case Read_Tag is
         when UTF_8 =>
            declare
               Length : constant u2.Big_Endian := u2.Big_Endian'Input (Stream);
               Bytes  : Standard.String (1 .. Standard.Integer (Length));
            begin
               Standard.String'Read (Stream, Bytes);
               Item.Include
                 (Constant_Pool_Position,
                  Constant_Pool_Entry'(UTF_8, new Standard.String'(Bytes)));
            end;

         when INTEGER =>
            Item.Include
              (Constant_Pool_Position,
               Constant_Pool_Entry'
                 (INTEGER, Standard.Integer (i4.Big_Endian'Input (Stream))));

         when FLOAT =>
            Item.Include
              (Constant_Pool_Position,
               Constant_Pool_Entry'
                 (FLOAT, u4_To_Float (u4.Big_Endian'Input (Stream))));

         when LONG =>
            Item.Include
              (Constant_Pool_Position,
               Constant_Pool_Entry'
                 (LONG, i8.Big_Endian'Input (Stream)));
            Constant_Pool_Position := @ + 1;

         when DOUBLE =>
            Item.Include
              (Constant_Pool_Position,
               Constant_Pool_Entry'
                 (DOUBLE, u8_To_Double (u8.Big_Endian'Input (Stream))));
            Constant_Pool_Position := @ + 1;

         when CLASS | STRING =>
            declare
               Name_Index : constant Constant_Pool_Index :=
                 Constant_Pool_Index'Input (Stream);
            begin
               if Item.Contains (Name_Index) then
                  declare
                     Utf8 : constant Utf_8_Constant_Pool_Entry :=
                       Utf_8_Constant_Pool_Entry (Item.Element (Name_Index));
                  begin
                     case Read_Tag is
                        when CLASS =>
                           Item.Include
                             (Constant_Pool_Position,
                              Constant_Pool_Entry'
                                (CLASS, new Utf_8_Constant_Pool_Entry'(Utf8)));

                        when STRING =>
                           Item.Include
                             (Constant_Pool_Position,
                              Constant_Pool_Entry'
                                (STRING,
                                 new Utf_8_Constant_Pool_Entry'(Utf8)));

                        when others =>
                           raise Constraint_Error;
                     end case;
                  end;
               else
                  case Read_Tag is
                     when CLASS =>
                        Incomplete_Map.Include
                          (Constant_Pool_Position,
                           Incomplete_Entry'(CLASS, Name_Index));

                     when STRING =>
                        Incomplete_Map.Include
                          (Constant_Pool_Position,
                           Incomplete_Entry'(STRING, Name_Index));

                     when others =>
                        raise Constraint_Error;
                  end case;
               end if;
            end;

         when FIELD_REFERENCE | METHOD_REFERENCE | INTERFACE_METHOD_REFERENCE
         =>
            declare
               Class_Index         : constant Constant_Pool_Index :=
                 Constant_Pool_Index'Input (Stream);
               Name_And_Type_Index : constant Constant_Pool_Index :=
                 Constant_Pool_Index'Input (Stream);
            begin
               if Item.Contains (Class_Index)
                 and then Item.Contains (Name_And_Type_Index)
               then
                  declare
                     Class         : constant Class_Constant_Pool_Entry :=
                       Class_Constant_Pool_Entry (Item.Element (Class_Index));
                     Name_And_Type :
                       constant Name_And_Type_Constant_Pool_Entry :=
                         Name_And_Type_Constant_Pool_Entry
                           (Item.Element (Name_And_Type_Index));
                  begin
                     case Read_Tag is
                        when FIELD_REFERENCE =>
                           Item.Include
                             (Constant_Pool_Position,
                              Constant_Pool_Entry'
                                (FIELD_REFERENCE,
                                 new Class_Constant_Pool_Entry'(Class),
                                   new Name_And_Type_Constant_Pool_Entry'
                                     (Name_And_Type)));

                        when METHOD_REFERENCE =>
                           Item.Include
                             (Constant_Pool_Position,
                              Constant_Pool_Entry'
                                (METHOD_REFERENCE,
                                 new Class_Constant_Pool_Entry'(Class),
                                   new Name_And_Type_Constant_Pool_Entry'
                                     (Name_And_Type)));

                        when INTERFACE_METHOD_REFERENCE =>
                           Item.Include
                             (Constant_Pool_Position,
                              Constant_Pool_Entry'
                                (INTERFACE_METHOD_REFERENCE,
                                 new Class_Constant_Pool_Entry'(Class),
                                   new Name_And_Type_Constant_Pool_Entry'
                                     (Name_And_Type)));

                        when others =>
                           raise Constraint_Error;
                     end case;
                  end;
               else
                  case Read_Tag is
                     when FIELD_REFERENCE =>
                        Incomplete_Map.Include
                          (Constant_Pool_Position,
                           Incomplete_Entry'
                             (FIELD_REFERENCE,
                              Class_Index,
                              Name_And_Type_Index));

                     when METHOD_REFERENCE =>
                        Incomplete_Map.Include
                          (Constant_Pool_Position,
                           Incomplete_Entry'
                             (METHOD_REFERENCE,
                              Class_Index,
                              Name_And_Type_Index));

                     when INTERFACE_METHOD_REFERENCE =>
                        Incomplete_Map.Include
                          (Constant_Pool_Position,
                           Incomplete_Entry'
                             (INTERFACE_METHOD_REFERENCE,
                              Class_Index,
                              Name_And_Type_Index));

                     when others =>
                        raise Constraint_Error;
                  end case;
               end if;
            end;

         when NAME_AND_TYPE =>
            declare
               Name_Index       : constant Constant_Pool_Index :=
                 Constant_Pool_Index'Input (Stream);
               Descriptor_Index : constant Constant_Pool_Index :=
                 Constant_Pool_Index'Input (Stream);
            begin
               if Item.Contains (Name_Index)
                 and then Item.Contains (Descriptor_Index)
               then
                  declare
                     Name       : constant Utf_8_Constant_Pool_Entry :=
                       Utf_8_Constant_Pool_Entry (Item.Element (Name_Index));
                     Descriptor : constant Utf_8_Constant_Pool_Entry :=
                       Utf_8_Constant_Pool_Entry
                         (Item.Element (Descriptor_Index));
                  begin
                     Item.Include
                       (Constant_Pool_Position,
                        Constant_Pool_Entry'
                          (NAME_AND_TYPE,
                           new Utf_8_Constant_Pool_Entry'(Name),

                           new Utf_8_Constant_Pool_Entry'(Descriptor)));
                  end;
               else
                  Incomplete_Map.Include
                    (Constant_Pool_Position,
                     Incomplete_Entry'
                       (NAME_AND_TYPE, Name_Index, Descriptor_Index));
               end if;
            end;
      end case;

      Constant_Pool_Position := @ + 1;
      exit when Constant_Pool_Position >= Constant_Pool_Count;
   end loop;
   Constant_Pool_Position := 1;
   loop
      Handle_Incomplete_Entry (Constant_Pool_Position);
      Constant_Pool_Position := @ + 1;
      exit when Constant_Pool_Position >= Constant_Pool_Index (Incomplete_Map.Length);
   end loop;
   if Constant_Pool_Count /= Constant_Pool_Index (Item.Last_Key) then
      raise Constraint_Error with "Constant Pool has incorrect size (" & Item.Length'Image & " /" & Item.Last_Key'Image & " /" & Constant_Pool_Count'Image & " )";
   end if;
end Read_Constant_Pool_Map;
