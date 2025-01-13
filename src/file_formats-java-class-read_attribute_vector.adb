---------------------------
-- Read_Attribute_Vector --
---------------------------

separate (File_Formats.Java.Class)
procedure Read_Attribute_Vector
  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
   Item   : out Attribute_Vectors.Vector'Class;
   Pool   : Constant_Pool_Maps.Map)
is
   Attribute_Type : Class_File_Attribute_Type;
begin
   for Index in 1 .. u2.Big_Endian'Input (Stream) loop
      declare
         Name   : constant Utf_8_Constant_Pool_Entry :=
           Utf_8_Constant_Pool_Entry
             (Pool.Element (Constant_Pool_Index'Input (Stream)));
         Length : constant u4.Big_Endian := u4.Big_Endian'Input (Stream);
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

            when ConstantValue =>
               Item.Append
                 (Class_File_Attribute'
                    (Attribute_Type => ConstantValue,
                     Name_Ref       => Name,
                     Constant_Value =>
                       new Constant_Pool_Entry'
                         (Pool.Element (Constant_Pool_Index'Input (Stream)))));

            when Code =>
               declare
                  Max_Stack_Size       : constant u2.Big_Endian :=
                    u2.Big_Endian'Input (Stream);
                  Local_Variable_Count : constant u2.Big_Endian :=
                    u2.Big_Endian'Input (Stream);
                  Code_Length          : constant Positive_u4 :=
                    Positive_u4'Input (Stream);
                  Code_Data            : Raw_Data_Filled (1 .. Code_Length);
                  Exception_Table      : CFA_Code_Exception_Vectors.Vector;
                  Attributes           : Attribute_Vector;
               begin
                  Raw_Data_Filled'Read (Stream, Code_Data);
                  for Index in 1 .. u2.Big_Endian'Input (Stream) loop
                     declare
                        Start, Stop, Handle : u2.Big_Endian;
                        Class_Idx           : u2.Big_Endian;
                     begin
                        u2.Big_Endian'Read (Stream, Start);
                        u2.Big_Endian'Read (Stream, Stop);
                        u2.Big_Endian'Read (Stream, Handle);
                        u2.Big_Endian'Read (Stream, Class_Idx);
                        Exception_Table.Append
                          (CFA_Code_Exception_Entry'
                             (Start,
                              Stop,
                              Handle,
                                (if Class_Idx = 0 then null
                                 else
                                   new Class_Constant_Pool_Entry'
                                     (Class_Constant_Pool_Entry
                                        (Pool.Element
                                           (Constant_Pool_Index
                                              (Class_Idx)))))));
                     end;
                  end loop;
                  Read_Attribute_Vector (Stream, Attributes, Pool);
                  Item.Append
                    (Class_File_Attribute'
                       (Attribute_Type       => Code,
                        Name_Ref             => Name,
                        Max_Stack_Size       => Max_Stack_Size,
                        Local_Variable_Count => Local_Variable_Count,
                        Code                 => new Raw_Data_Filled'(Code_Data),
                        Exception_Table      => Exception_Table,
                        Attributes           =>
                          new Attribute_Vector'(Attributes)));
               end;

            when Exceptions =>
               declare
                  New_Entry : Class_File_Attribute := (Attribute_Type => Exceptions, Name_Ref => Name, others => <>);
               begin
                  for Index in 1 .. u2.Big_Endian'Input (Stream) loop
                     New_Entry.Exceptions_Table.Append (Class_Constant_Pool_Entry (Pool.Element (Constant_Pool_Index'Input (Stream))));
                  end loop;
                  Item.Append (New_Entry);
               end;

            when LineNumberTable =>
               declare
                  New_Entry : Class_File_Attribute := (Attribute_Type => LineNumberTable, Name_Ref => Name, others => <>);
               begin
                  for Index in 1 .. u2.Big_Endian'Input (Stream) loop
                     New_Entry.Line_Number_Table.Append (CFA_LineNumberTable_Line_Entry'(u2.Big_Endian'Input (Stream), u2.Big_Endian'Input (Stream)));
                  end loop;
                  Item.Append (New_Entry);
               end;

            when Other =>
               declare
                  Data : Raw_Data (1 .. Length);
               begin
                  Raw_Data'Read (Stream, Data);
                  Item.Append
                    (Class_File_Attribute'
                       (Attribute_Type => Other,
                        Name_Ref       => Name,
                        Data           => new Raw_Data'(Data)));
               end;

            when others =>
               raise Constraint_Error with Attribute_Type'Image;
         end case;
      end;
   end loop;
end Read_Attribute_Vector;
