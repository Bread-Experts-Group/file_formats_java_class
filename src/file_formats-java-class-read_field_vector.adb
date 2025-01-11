with Ada.Unchecked_Conversion;

-----------------------
-- Read_Field_Vector --
-----------------------

separate (File_Formats.Java.Class)
procedure Read_Field_Vector
   (Stream      : not null access Ada.Streams.Root_Stream_Type'Class;
    Item        : out Field_Vectors.Vector;
    Pool        : Constant_Pool_Maps.Map;
    Environment : Class_File_Environment)
is
   Access_Flags : Class_File_Field_Access_Flags;
   function u2_To_Field_Access_Flags is new Ada.Unchecked_Conversion (u2.Big_Endian, Class_File_Field_Access_Flags);
begin
   for Index in 1 .. u2.Big_Endian'Input (Stream) loop
      Access_Flags := u2_To_Field_Access_Flags (u2.Big_Endian'Input (Stream));
      declare
         Name       : constant Constant_Pool_Entry := Pool.Element (Constant_Pool_Index'Input (Stream));
         Descriptor : constant Constant_Pool_Entry := Pool.Element (Constant_Pool_Index'Input (Stream));
         Field      : Class_File_Field (Environment);
      begin
         case Environment is
            when CLASS =>
               Field := (Environment => CLASS, Access_Flags_Class => Access_Flags, Name_Ref => Utf_8_Constant_Pool_Entry (Name), Descriptor_Ref => Utf_8_Constant_Pool_Entry (Descriptor), others => <>);
               Read_Attribute_Vector (Stream, Field.Attributes);
               Item.Append (Field);
            when IS_INTERFACE =>
               Field := (Environment => IS_INTERFACE, Access_Flags_Others => Class_File_Field_Access_Flags_Any (Access_Flags), Name_Ref => Utf_8_Constant_Pool_Entry (Name), Descriptor_Ref => Utf_8_Constant_Pool_Entry (Descriptor), others => <>);
               Read_Attribute_Vector (Stream, Field.Attributes);
               Item.Append (Field);
         end case;
      end;
   end loop;
end Read_Field_Vector;