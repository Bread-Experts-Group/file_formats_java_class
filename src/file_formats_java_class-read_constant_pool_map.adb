with Ada.Unchecked_Conversion;

----------------------------
-- Read_Constant_Pool_Map --
----------------------------

separate (File_Formats_Java_Class)
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

         when METHOD_HANDLE =>
            Kind          : Method_Handle_Reference_Kind;
            Reference_Ref : Constant_Pool_Index;

         when METHOD_TYPE =>
            Method_Descriptor_Ref : Constant_Pool_Index;

         when INVOKE_DYNAMIC =>
            Bootstrap_Method_Index   : u2.Big_Endian;
            Method_Name_And_Type_Ref : Constant_Pool_Index;

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
                  Class_Ref         : constant Class_Constant_Pool_Entry :=
                    Class_Constant_Pool_Entry
                      (Item.Element (Incomplete.Class_Ref));
                  Name_And_Type_Ref :
                    constant Name_And_Type_Constant_Pool_Entry :=
                      Name_And_Type_Constant_Pool_Entry
                        (Item.Element (Incomplete.Name_And_Type_Ref));
               begin
                  case Incomplete.Tag is
                     when FIELD_REFERENCE =>
                        Item.Include
                          (Index,
                           Constant_Pool_Entry'
                             (FIELD_REFERENCE,
                              new Class_Constant_Pool_Entry'(Class_Ref),

                                new Name_And_Type_Constant_Pool_Entry'
                                  (Name_And_Type_Ref)));

                     when METHOD_REFERENCE =>
                        Item.Include
                          (Index,
                           Constant_Pool_Entry'
                             (METHOD_REFERENCE,
                              new Class_Constant_Pool_Entry'(Class_Ref),

                                new Name_And_Type_Constant_Pool_Entry'
                                  (Name_And_Type_Ref)));

                     when INTERFACE_METHOD_REFERENCE =>
                        Item.Include
                          (Index,
                           Constant_Pool_Entry'
                             (INTERFACE_METHOD_REFERENCE,
                              new Class_Constant_Pool_Entry'(Class_Ref),

                                new Name_And_Type_Constant_Pool_Entry'
                                  (Name_And_Type_Ref)));

                     when others =>
                        raise Impossible_Branch;
                  end case;
               end;

            when METHOD_HANDLE =>
               Handle_Incomplete_Entry (Incomplete.Reference_Ref);
               declare
                  Reference : constant Constant_Pool_Entry :=
                    Item.Element (Incomplete.Reference_Ref);
               begin
                  Item.Include
                    (Index,
                     Constant_Pool_Entry'
                       (METHOD_HANDLE,
                        Incomplete.Kind,
                        new Constant_Pool_Entry'(Reference)));
               end;

            when METHOD_TYPE =>
               Item.Include
                 (Index,
                  Constant_Pool_Entry'
                    (METHOD_TYPE,

                       new Utf_8_Constant_Pool_Entry'
                         (Utf_8_Constant_Pool_Entry
                            (Item.Element
                               (Incomplete.Method_Descriptor_Ref)))));

            when INVOKE_DYNAMIC =>
               Handle_Incomplete_Entry (Incomplete.Method_Name_And_Type_Ref);
               declare
                  Method_Name_And_Type :
                    constant Name_And_Type_Constant_Pool_Entry :=
                      Name_And_Type_Constant_Pool_Entry
                        (Item.Element (Incomplete.Method_Name_And_Type_Ref));
               begin
                  Item.Include
                    (Index,
                     Constant_Pool_Entry'
                       (INVOKE_DYNAMIC,
                        Incomplete.Bootstrap_Method_Index,

                          new Name_And_Type_Constant_Pool_Entry'
                            (Method_Name_And_Type)));
               end;

            when others =>
               raise Possible_Misalignment
                 with
                   "A complete entry of "
                   & Incomplete'Image
                   & " at index"
                   & Index'Image
                   & " was added to the incomplete pool";
         end case;
      end;
   end Handle_Incomplete_Entry;
begin
   i2.Big_Endian'Read (Stream, Constant_Pool_Count);
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
               Constant_Pool_Entry'(LONG, i8.Big_Endian'Input (Stream)));
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
                           raise Impossible_Branch;
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
                        raise Impossible_Branch;
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
                     Class_Ref         : constant Class_Constant_Pool_Entry :=
                       Class_Constant_Pool_Entry (Item.Element (Class_Index));
                     Name_And_Type_Ref :
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
                                 new Class_Constant_Pool_Entry'(Class_Ref),

                                   new Name_And_Type_Constant_Pool_Entry'
                                     (Name_And_Type_Ref)));

                        when METHOD_REFERENCE =>
                           Item.Include
                             (Constant_Pool_Position,
                              Constant_Pool_Entry'
                                (METHOD_REFERENCE,
                                 new Class_Constant_Pool_Entry'(Class_Ref),

                                   new Name_And_Type_Constant_Pool_Entry'
                                     (Name_And_Type_Ref)));

                        when INTERFACE_METHOD_REFERENCE =>
                           Item.Include
                             (Constant_Pool_Position,
                              Constant_Pool_Entry'
                                (INTERFACE_METHOD_REFERENCE,
                                 new Class_Constant_Pool_Entry'(Class_Ref),

                                   new Name_And_Type_Constant_Pool_Entry'
                                     (Name_And_Type_Ref)));

                        when others =>
                           raise Impossible_Branch;
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
                        raise Impossible_Branch;
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

         when METHOD_HANDLE =>
            declare
               Kind            : constant Method_Handle_Reference_Kind :=
                 Method_Handle_Reference_Kind'Input (Stream);
               Reference_Index : constant Constant_Pool_Index :=
                 Constant_Pool_Index'Input (Stream);
            begin
               if Item.Contains (Reference_Index) then
                  declare
                     Reference : constant Constant_Pool_Entry :=
                       Item.Element (Reference_Index);
                  begin
                     Item.Include
                       (Constant_Pool_Position,
                        Constant_Pool_Entry'
                          (METHOD_HANDLE,
                           Kind,
                           new Constant_Pool_Entry'(Reference)));
                  end;
               else
                  Incomplete_Map.Include
                    (Constant_Pool_Position,
                     Incomplete_Entry'(METHOD_HANDLE, Kind, Reference_Index));
               end if;
            end;

         when METHOD_TYPE =>
            declare
               Descriptor_Index : constant Constant_Pool_Index :=
                 Constant_Pool_Index'Input (Stream);
            begin
               if Item.Contains (Descriptor_Index) then
                  declare
                     Descriptor : constant Utf_8_Constant_Pool_Entry :=
                       Utf_8_Constant_Pool_Entry
                         (Item.Element (Descriptor_Index));
                  begin
                     Item.Include
                       (Constant_Pool_Position,
                        Constant_Pool_Entry'
                          (METHOD_TYPE,
                           new Utf_8_Constant_Pool_Entry'(Descriptor)));
                  end;
               else
                  Incomplete_Map.Include
                    (Constant_Pool_Position,
                     Incomplete_Entry'(METHOD_TYPE, Descriptor_Index));
               end if;
            end;

         when INVOKE_DYNAMIC =>
            declare
               Bootstrap_Method_Index     : constant u2.Big_Endian :=
                 u2.Big_Endian'Input (Stream);
               Method_Name_And_Type_Index : constant Constant_Pool_Index :=
                 Constant_Pool_Index'Input (Stream);
            begin
               if Item.Contains (Method_Name_And_Type_Index) then
                  declare
                     Method_Name_And_Type :
                       constant Name_And_Type_Constant_Pool_Entry :=
                         Name_And_Type_Constant_Pool_Entry
                           (Item.Element (Method_Name_And_Type_Index));
                  begin
                     Item.Include
                       (Constant_Pool_Position,
                        Constant_Pool_Entry'
                          (INVOKE_DYNAMIC,
                           Bootstrap_Method_Index,

                             new Name_And_Type_Constant_Pool_Entry'
                               (Method_Name_And_Type)));
                  end;
               else
                  Incomplete_Map.Include
                    (Constant_Pool_Position,
                     Incomplete_Entry'
                       (INVOKE_DYNAMIC,
                        Bootstrap_Method_Index,
                        Method_Name_And_Type_Index));
               end if;
            end;
      end case;

      Constant_Pool_Position := @ + 1;
      exit when Constant_Pool_Position >= Constant_Pool_Count;
   end loop;

   for Incomplete_Entry_Element in Incomplete_Map.Iterate loop
      Handle_Incomplete_Entry
        (Incomplete_Pool_Maps.Key (Incomplete_Entry_Element));
   end loop;
   Incomplete_Map.Clear;

   if (Constant_Pool_Count - 1) /= Constant_Pool_Index (Item.Last_Key) then
      raise Possible_Misalignment
        with
          "Constant Pool has incorrect size ("
          & Item.Length'Image
          & " /"
          & Item.Last_Key'Image
          & " /"
          & Constant_Pool_Index'(Constant_Pool_Count - 1)'Image
          & " )";
   end if;
end Read_Constant_Pool_Map;
