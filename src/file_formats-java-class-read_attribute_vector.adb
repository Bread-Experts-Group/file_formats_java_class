---------------------------
-- Read_Attribute_Vector --
---------------------------

separate (File_Formats.Java.Class)
procedure Read_Attribute_Vector
  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
   Item   : out Attribute_Vectors.Vector;
   Pool   : Constant_Pool_Maps.Map)
is
   Attribute_Type : Class_File_Attribute_Type;
begin
   for Index in 1 .. u2.Big_Endian'Input (Stream) loop
      declare
         Name : constant Utf_8_Constant_Pool_Entry :=
           Utf_8_Constant_Pool_Entry
             (Pool.Element (Constant_Pool_Index'Input (Stream)));
      begin
         begin
            Attribute_Type :=
              Class_File_Attribute_Type'Value (Name.Utf_Bytes.all);
         exception
            when others =>
               Attribute_Type := Other;
         end;
         case Attribute_Type is
            when SourceFile =>
               Item.Append
                 (Class_File_Attribute'
                    (Attribute_Type => SourceFile,
                     Name_Ref       => Name,
                     Source_File    =>
                       Utf_8_Constant_Pool_Entry
                         (Pool.Element (Constant_Pool_Index'Input (Stream)))));

            when others =>
               declare
                  Data : Raw_Data (1 .. u4.Big_Endian'Input (Stream));
               begin
                  Raw_Data'Read (Stream, Data);
                  Item.Append
                    (Class_File_Attribute'
                       (Attribute_Type => Other,
                        Name_Ref       => Name,
                        Data           => new Raw_Data'(Data)));
               end;
         end case;
      end;
   end loop;
end Read_Attribute_Vector;
