with Ada.Unchecked_Conversion;

-----------------------
-- Read_Field_Vector --
-----------------------

separate (File_Formats_Java_Class)
procedure Read_Field_Vector
  (Stream      : not null access Ada.Streams.Root_Stream_Type'Class;
   Item        : out Field_Vectors.Vector;
   Pool        : Constant_Pool_Maps.Map;
   Environment : Class_File_Environment)
is
   Access_Flags : Class_File_Field_Access_Flags;
   function u2_To_Field_Access_Flags is new
     Ada.Unchecked_Conversion (u2.Big_Endian, Class_File_Field_Access_Flags);
begin
   for Index in 1 .. u2.Big_Endian'Input (Stream) loop
      Access_Flags := u2_To_Field_Access_Flags (u2.Big_Endian'Input (Stream));
      declare
         Name       : constant Constant_Pool_Entry :=
           Pool.Element (Constant_Pool_Index'Input (Stream));
         Descriptor : constant Constant_Pool_Entry :=
           Pool.Element (Constant_Pool_Index'Input (Stream));
      begin
         case Environment is
            when CLASS =>
               declare
                  Field : Class_File_Field :=
                    (Environment        => CLASS,
                     Access_Flags       => Access_Flags,
                     Name_Ref           => Utf_8_Constant_Pool_Entry (Name),
                     Descriptor_Ref     =>
                       Utf_8_Constant_Pool_Entry (Descriptor),
                     others             => <>);
               begin
                  Read_Attribute_Vector (Stream, Field.Attributes, Pool);
                  Item.Append (Field);
               end;

            when IS_INTERFACE =>
               declare
                  Field : Class_File_Field :=
                    (Environment         => IS_INTERFACE,
                     Access_Flags        => Access_Flags,
                     Name_Ref            => Utf_8_Constant_Pool_Entry (Name),
                     Descriptor_Ref      =>
                       Utf_8_Constant_Pool_Entry (Descriptor),
                     others              => <>);
               begin
                  Read_Attribute_Vector (Stream, Field.Attributes, Pool);
                  Item.Append (Field);
               end;
         end case;
      end;
   end loop;
end Read_Field_Vector;
