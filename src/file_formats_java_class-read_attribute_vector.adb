with Ada.Unchecked_Conversion;

---------------------------
-- Read_Attribute_Vector --
---------------------------

separate (File_Formats_Java_Class)
procedure Read_Attribute_Vector
  (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
   Item   : out Attribute_Vectors.Vector'Class;
   Pool   : Constant_Pool_Maps.Map)
is
   Attribute_Type : Class_File_Attribute_Type;
begin
   for Attribute_Index in 1 .. u2.Big_Endian'Input (Stream) loop
      declare
         Name   : constant Utf_8_Constant_Pool_Entry :=
           Utf_8_Constant_Pool_Entry
             (Pool.Element (Constant_Pool_Index'Input (Stream)));
         Length : constant u4.Big_Endian := u4.Big_Endian'Input (Stream);
         Data : Octet_Memory_Stream.Octet_Array (0 .. Ada.Streams.Stream_Element_Offset (Length));
      begin
         Octet_Memory_Stream.Octet_Array'Read (Stream, Data);
         begin
            Attribute_Type :=
              Class_File_Attribute_Type'Value (Name.Utf_Bytes.all);
         exception
            when others =>
               Attribute_Type := Other;
         end;
         declare
            Attribute_Stream : constant Octet_Memory_Stream.Memory_Stream_Access :=
               Octet_Memory_Stream.To_Stream (Data);
            function Read_Annotation return CFA_Annotation;

            function Read_Element_Value return CFA_Annotation_Element_Value is
               Tag : constant Character := Character'Input (Attribute_Stream);
            begin
               case Tag is
                  when 'B' =>
                     return
                     (Tag            => 'B',
                        Constant_Value =>
                        new Constant_Pool_Entry'
                           (Pool.Element (Constant_Pool_Index'Input (Attribute_Stream))));

                  when 'C' =>
                     return
                     (Tag            => 'C',
                        Constant_Value =>
                        new Constant_Pool_Entry'
                           (Pool.Element (Constant_Pool_Index'Input (Attribute_Stream))));

                  when 'D' =>
                     return
                     (Tag            => 'D',
                        Constant_Value =>
                        new Constant_Pool_Entry'
                           (Pool.Element (Constant_Pool_Index'Input (Attribute_Stream))));

                  when 'F' =>
                     return
                     (Tag            => 'F',
                        Constant_Value =>
                        new Constant_Pool_Entry'
                           (Pool.Element (Constant_Pool_Index'Input (Attribute_Stream))));

                  when 'I' =>
                     return
                     (Tag            => 'I',
                        Constant_Value =>
                        new Constant_Pool_Entry'
                           (Pool.Element (Constant_Pool_Index'Input (Attribute_Stream))));

                  when 'J' =>
                     return
                     (Tag            => 'J',
                        Constant_Value =>
                        new Constant_Pool_Entry'
                           (Pool.Element (Constant_Pool_Index'Input (Attribute_Stream))));

                  when 'S' =>
                     return
                     (Tag            => 'S',
                        Constant_Value =>
                        new Constant_Pool_Entry'
                           (Pool.Element (Constant_Pool_Index'Input (Attribute_Stream))));

                  when 'Z' =>
                     return
                     (Tag            => 'Z',
                        Constant_Value =>
                        new Constant_Pool_Entry'
                           (Pool.Element (Constant_Pool_Index'Input (Attribute_Stream))));

                  when 's' =>
                     return
                     (Tag            => 's',
                        Constant_Value =>
                        new Constant_Pool_Entry'
                           (Pool.Element (Constant_Pool_Index'Input (Attribute_Stream))));

                  when 'e' =>
                     declare
                        Type_Name_Idx  : constant Constant_Pool_Index :=
                        Constant_Pool_Index'Input (Attribute_Stream);
                        Const_Name_Idx : constant Constant_Pool_Index :=
                        Constant_Pool_Index'Input (Attribute_Stream);
                     begin
                        return
                        (Tag                => 'e',
                           Field_Descriptor   =>
                           Utf_8_Constant_Pool_Entry
                              (Pool.Element (Type_Name_Idx)),
                           Enum_Constant_Name =>
                           Utf_8_Constant_Pool_Entry
                              (Pool.Element (Const_Name_Idx)));
                     end;

                  when 'c' =>
                     return
                     (Tag               => 'c',
                        Return_Descriptor =>
                        Utf_8_Constant_Pool_Entry
                           (Pool.Element (Constant_Pool_Index'Input (Attribute_Stream))));

                  when '@' =>
                     return
                     (Tag        => '@',
                        Annotation => new CFA_Annotation'(Read_Annotation));

                  when '[' =>
                     declare
                        Vector : CFA_Annotation_Element_Value_Vector;
                     begin
                        for Element_Index in 1 .. u2.Big_Endian'Input (Attribute_Stream)
                        loop
                           Vector.Append (Read_Element_Value);
                        end loop;
                        return
                        (Tag            => '[',
                           Element_Values =>
                           new CFA_Annotation_Element_Value_Vector'(Vector));
                     end;

                  when others =>
                     return raise Possible_Misalignment with "Element Value has bad tag of " & Tag'Image;
               end case;
            end Read_Element_Value;

            function Read_Annotation return CFA_Annotation is
               New_Annotation : CFA_Annotation :=
               (Field_Descriptor =>
                  Utf_8_Constant_Pool_Entry
                     (Pool.Element
                        (Constant_Pool_Index'Input (Attribute_Stream))),
                  others           => <>);
            begin
               for Index in 1 .. u2.Big_Endian'Input (Attribute_Stream) loop
                  declare
                     Annotation_Name : constant Utf_8_Constant_Pool_Entry :=
                     Utf_8_Constant_Pool_Entry
                        (Pool.Element
                           (Constant_Pool_Index'Input (Attribute_Stream)));
                     Value           : constant CFA_Annotation_Element_Value :=
                     Read_Element_Value;
                  begin
                     New_Annotation.Element_Value_Pairs.Append
                     (CFA_Annotation_Element_Value_Pair'
                        (Annotation_Name,
                           new CFA_Annotation_Element_Value'(Value)));
                  end;
               end loop;
               return New_Annotation;
            end Read_Annotation;
         begin
            case Attribute_Type is
               when ConstantValue =>
                  Item.Append
                     (Class_File_Attribute'
                        (Attribute_Type => ConstantValue,
                        Name_Ref       => Name,
                        Constant_Value =>
                           new Constant_Pool_Entry'
                              (Pool.Element (Constant_Pool_Index'Input (Attribute_Stream)))));

               when Code =>
                  declare
                     Max_Stack_Size       : constant u2.Big_Endian :=
                        u2.Big_Endian'Input (Attribute_Stream);
                     Local_Variable_Count : constant u2.Big_Endian :=
                        u2.Big_Endian'Input (Attribute_Stream);
                     Code_Length          : constant Positive_u4 :=
                        Positive_u4'Input (Attribute_Stream);
                     Code_Data            : Raw_Data_Filled (1 .. Code_Length);
                     Exception_Table      : CFA_Code_Exception_Vectors.Vector;
                     Attributes           : Attribute_Vector;
                  begin
                     Raw_Data_Filled'Read (Attribute_Stream, Code_Data);
                     for Index in 1 .. u2.Big_Endian'Input (Attribute_Stream) loop
                        declare
                           Start, Stop, Handle : u2.Big_Endian;
                           Class_Idx           : u2.Big_Endian;
                        begin
                           u2.Big_Endian'Read (Attribute_Stream, Start);
                           u2.Big_Endian'Read (Attribute_Stream, Stop);
                           u2.Big_Endian'Read (Attribute_Stream, Handle);
                           u2.Big_Endian'Read (Attribute_Stream, Class_Idx);
                           Exception_Table.Append
                              (CFA_Code_Exception_Entry'
                                 (Program_Counter_Start   => Start,
                                 Program_Counter_Stop    => Stop,
                                 Program_Counter_Handler => Handle,

                                 Catch                   =>
                                    (if Class_Idx = 0 then null
                                    else
                                       new Class_Constant_Pool_Entry'
                                          (Class_Constant_Pool_Entry
                                             (Pool.Element
                                                (Constant_Pool_Index
                                                   (Class_Idx)))))));
                        end;
                     end loop;
                     Read_Attribute_Vector (Attribute_Stream, Attributes, Pool);
                     Item.Append
                        (Class_File_Attribute'
                           (Attribute_Type       => Code,
                           Name_Ref             => Name,
                           Max_Stack_Size       => Max_Stack_Size,
                           Local_Variable_Count => Local_Variable_Count,
                           Code                 =>
                              new Raw_Data_Filled'(Code_Data),
                           Exception_Table      => Exception_Table,
                           Attributes           =>
                              new Attribute_Vector'(Attributes)));
                  end;

               when StackMapTable =>
                  declare
                     New_Entry  : Class_File_Attribute :=
                        (Attribute_Type => StackMapTable,
                        Name_Ref       => Name,
                        others         => <>);
                     Frame_Type : Byteflippers.Unsigned_8;

                     use type Byteflippers.Unsigned_8;

                     function Read_Type_Info_Vector
                        (Count : u2.Big_Endian)
                        return CFA_SMT_Verification_Type_Info_Vectors.Vector
                     is
                        Vector : CFA_SMT_Verification_Type_Info_Vectors.Vector;
                        Tag    : CFA_SMT_Variable_Tag;
                     begin
                        for Index in 1 .. Count loop
                           CFA_SMT_Variable_Tag'Read (Attribute_Stream, Tag);
                           case Tag is
                              when ITEM_TOP =>
                                 Vector.Append
                                    (CFA_SMT_Verification_Type_Info'
                                       (Tag => ITEM_TOP));

                              when ITEM_INTEGER =>
                                 Vector.Append
                                    (CFA_SMT_Verification_Type_Info'
                                       (Tag => ITEM_INTEGER));

                              when ITEM_FLOAT =>
                                 Vector.Append
                                    (CFA_SMT_Verification_Type_Info'
                                       (Tag => ITEM_FLOAT));

                              when ITEM_DOUBLE =>
                                 Vector.Append
                                    (CFA_SMT_Verification_Type_Info'
                                       (Tag => ITEM_DOUBLE));

                              when ITEM_LONG =>
                                 Vector.Append
                                    (CFA_SMT_Verification_Type_Info'
                                       (Tag => ITEM_LONG));

                              when ITEM_NULL =>
                                 Vector.Append
                                    (CFA_SMT_Verification_Type_Info'
                                       (Tag => ITEM_NULL));

                              when ITEM_UNINITIALIZED_THIS =>
                                 Vector.Append
                                    (CFA_SMT_Verification_Type_Info'
                                       (Tag => ITEM_UNINITIALIZED_THIS));

                              when ITEM_OBJECT =>
                                 Vector.Append
                                    (CFA_SMT_Verification_Type_Info'
                                       (Tag             => ITEM_OBJECT,
                                       Instance_Of_Ref =>
                                          Class_Constant_Pool_Entry
                                             (Pool.Element
                                                (Constant_Pool_Index'Input
                                                   (Attribute_Stream)))));

                              when ITEM_UNINTIALIZED =>
                                 Vector.Append
                                    (CFA_SMT_Verification_Type_Info'
                                       (Tag         => ITEM_UNINTIALIZED,
                                       Code_Offset =>
                                          u2.Big_Endian'Input (Attribute_Stream)));
                           end case;
                        end loop;
                        return Vector;
                     end Read_Type_Info_Vector;
                  begin
                     for Index in 1 .. u2.Big_Endian'Input (Attribute_Stream) loop
                        Byteflippers.Unsigned_8'Read (Attribute_Stream, Frame_Type);
                        case Frame_Type is
                           when 0 .. 63 =>
                              New_Entry.Stack_Map_Table.Append
                                 (CFA_StackMapTable_Frame'
                                    (Frame_Type   => SAME,
                                    Offset_Delta => u2.Big_Endian (Frame_Type)));

                           when 64 .. 127 =>
                              New_Entry.Stack_Map_Table.Append
                                 (CFA_StackMapTable_Frame'
                                    (Frame_Type     => SAME_LOCALS_1_STACK_ITEM,
                                    Offset_Delta   =>
                                       u2.Big_Endian (Frame_Type) - 64,
                                    SL1_Stack_Item =>
                                       new CFA_SMT_Verification_Type_Info'
                                          (Read_Type_Info_Vector (1)
                                             .First_Element)));

                           when 128 .. 246 =>
                              raise Possible_Misalignment
                                 with
                                    "SMT Reserved,"
                                    & Frame_Type'Image
                                    & ", index:"
                                    & Index'Image
                                    & ' '
                                    & New_Entry.Stack_Map_Table'Image;

                           when 247 =>
                              declare
                                 Offset_Delta : constant u2.Big_Endian :=
                                    u2.Big_Endian'Input (Attribute_Stream);
                              begin
                                 New_Entry.Stack_Map_Table.Append
                                    (CFA_StackMapTable_Frame'
                                       (Frame_Type      =>
                                          SAME_LOCALS_1_STACK_ITEM_EXTENDED,
                                       Offset_Delta    => Offset_Delta,
                                       SL1E_Stack_Item =>
                                          new CFA_SMT_Verification_Type_Info'
                                             (Read_Type_Info_Vector (1)
                                                .First_Element)));
                              end;

                           when 248 .. 250 =>
                              New_Entry.Stack_Map_Table.Append
                                 (CFA_StackMapTable_Frame'
                                    (Frame_Type   => CHOP,
                                    Offset_Delta =>
                                       u2.Big_Endian'Input (Attribute_Stream)));

                           when 251 =>
                              New_Entry.Stack_Map_Table.Append
                                 (CFA_StackMapTable_Frame'
                                    (Frame_Type   => SAME_FRAME_EXTENDED,
                                    Offset_Delta =>
                                       u2.Big_Endian'Input (Attribute_Stream)));

                           when 252 .. 254 =>
                              declare
                                 Offset_Delta : constant u2.Big_Endian :=
                                    u2.Big_Endian'Input (Attribute_Stream);
                              begin
                                 New_Entry.Stack_Map_Table.Append
                                    (CFA_StackMapTable_Frame'
                                       (Frame_Type   => APPEND,
                                       Offset_Delta => Offset_Delta,
                                       APPEND_Stack =>
                                          Read_Type_Info_Vector
                                             (u2.Big_Endian (Frame_Type - 251))));
                              end;

                           when 255 =>
                              declare
                                 Offset_Delta : constant u2.Big_Endian :=
                                    u2.Big_Endian'Input (Attribute_Stream);
                                 Local_Count  : constant u2.Big_Endian :=
                                    u2.Big_Endian'Input (Attribute_Stream);
                                 Locals       :
                                    constant CFA_SMT_Verification_Type_Info_Vectors
                                                .Vector :=
                                       Read_Type_Info_Vector (Local_Count);
                                 Stack_Count  : constant u2.Big_Endian :=
                                    u2.Big_Endian'Input (Attribute_Stream);
                                 Stack        :
                                    constant CFA_SMT_Verification_Type_Info_Vectors
                                                .Vector :=
                                       Read_Type_Info_Vector (Stack_Count);
                              begin
                                 New_Entry.Stack_Map_Table.Append
                                    (CFA_StackMapTable_Frame'
                                       (Frame_Type   => FULL_FRAME,
                                       Offset_Delta => Offset_Delta,
                                       FF_Locals    => Locals,
                                       FF_Stack     => Stack));
                              end;
                        end case;
                     end loop;
                  end;

               when Exceptions =>
                  declare
                     New_Entry : Class_File_Attribute :=
                        (Attribute_Type => Exceptions,
                        Name_Ref       => Name,
                        others         => <>);
                  begin
                     for Index in 1 .. u2.Big_Endian'Input (Attribute_Stream) loop
                        New_Entry.Exceptions_Table.Append
                           (Class_Constant_Pool_Entry
                              (Pool.Element (Constant_Pool_Index'Input (Attribute_Stream))));
                     end loop;
                     Item.Append (New_Entry);
                  end;

               when InnerClasses =>
                  declare
                     New_Entry : Class_File_Attribute :=
                        (Attribute_Type => InnerClasses,
                        Name_Ref       => Name,
                        others         => <>);
                  begin
                     for Index in 1 .. u2.Big_Endian'Input (Attribute_Stream) loop
                        declare
                           Inner_Idx, Outer_Idx : u2.Big_Endian;
                           Inner_Name_Idx       : u2.Big_Endian;
                           Access_Flags_Raw     : u2.Big_Endian;

                           function u2_To_Access_Flags is new
                              Ada.Unchecked_Conversion
                                 (u2.Big_Endian,
                                 CFA_InnerClasses_Access_Flags);
                        begin
                           u2.Big_Endian'Read (Attribute_Stream, Inner_Idx);
                           u2.Big_Endian'Read (Attribute_Stream, Outer_Idx);
                           u2.Big_Endian'Read (Attribute_Stream, Inner_Name_Idx);
                           u2.Big_Endian'Read (Attribute_Stream, Access_Flags_Raw);
                           New_Entry.Inner_Classes.Append
                              (CFA_InnerClasses_Class_Entry'
                                 (Inner_Class        =>
                                    (if Inner_Idx = 0 then null
                                    else
                                       new Class_Constant_Pool_Entry'
                                          (Class_Constant_Pool_Entry
                                             (Pool.Element
                                                (Constant_Pool_Index
                                                   (Inner_Idx))))),

                                 Outer_Class        =>
                                    (if Outer_Idx = 0 then null
                                    else
                                       new Class_Constant_Pool_Entry'
                                          (Class_Constant_Pool_Entry
                                             (Pool.Element
                                                (Constant_Pool_Index
                                                   (Outer_Idx))))),

                                 Inner_Class_Name   =>
                                    (if Inner_Name_Idx = 0 then null
                                    else
                                       new Utf_8_Constant_Pool_Entry'
                                          (Utf_8_Constant_Pool_Entry
                                             (Pool.Element
                                                (Constant_Pool_Index
                                                   (Inner_Name_Idx))))),
                                 Inner_Class_Access =>
                                    u2_To_Access_Flags (Access_Flags_Raw)));
                        end;
                     end loop;
                     Item.Append (New_Entry);
                  end;

               when EnclosingMethod =>
                  declare
                     Enclosing_Class      : constant Class_Constant_Pool_Entry :=
                        Class_Constant_Pool_Entry
                           (Pool.Element (Constant_Pool_Index'Input (Attribute_Stream)));
                     Enclosing_Method_Idx : constant u2.Big_Endian :=
                        u2.Big_Endian'Input (Attribute_Stream);
                  begin
                     Item.Append
                        (Class_File_Attribute'
                           (Attribute_Type   => EnclosingMethod,
                           Name_Ref         => Name,
                           Enclosing_Class  => Enclosing_Class,
                           Enclosing_Method =>
                              (if Enclosing_Method_Idx = 0 then null
                              else
                                 new Name_And_Type_Constant_Pool_Entry'
                                    (Name_And_Type_Constant_Pool_Entry
                                       (Pool.Element
                                          (Constant_Pool_Index
                                             (Enclosing_Method_Idx)))))));
                  end;

               when Synthetic =>
                  Item.Append
                     (Class_File_Attribute'
                        (Attribute_Type => Synthetic, Name_Ref => Name));

               when Signature =>
                  Item.Append
                     (Class_File_Attribute'
                        (Attribute_Type    => Signature,
                        Name_Ref          => Name,
                        Generic_Signature =>
                           Utf_8_Constant_Pool_Entry
                              (Pool.Element (Constant_Pool_Index'Input (Attribute_Stream)))));

               when SourceFile =>
                  Item.Append
                     (Class_File_Attribute'
                        (Attribute_Type => SourceFile,
                        Name_Ref       => Name,
                        Source_File    =>
                           Utf_8_Constant_Pool_Entry
                              (Pool.Element (Constant_Pool_Index'Input (Attribute_Stream)))));

               when LineNumberTable =>
                  declare
                     New_Entry : Class_File_Attribute :=
                        (Attribute_Type => LineNumberTable,
                        Name_Ref       => Name,
                        others         => <>);
                  begin
                     for Index in 1 .. u2.Big_Endian'Input (Attribute_Stream) loop
                        New_Entry.Line_Number_Table.Append
                           (CFA_LineNumberTable_Line_Entry'
                              (Program_Counter_Start =>
                                 u2.Big_Endian'Input (Attribute_Stream),
                              Line_Number           =>
                                 u2.Big_Endian'Input (Attribute_Stream)));
                     end loop;
                     Item.Append (New_Entry);
                  end;

               when LocalVariableTable =>
                  declare
                     Local_Variable_Vector : CFA_LocalVariableTable_Variable_Vectors.Vector;
                  begin
                     for Index in 1 .. u2.Big_Endian'Input (Attribute_Stream) loop
                        Local_Variable_Vector.Append
                          (CFA_LocalVariableTable_Variable_Entry'
                             (Program_Counter_Start  =>
                                u2.Big_Endian'Input (Attribute_Stream),
                              Program_Counter_Length =>
                                u2.Big_Endian'Input (Attribute_Stream),
                              Name_Ref               =>
                                Utf_8_Constant_Pool_Entry
                                  (Pool.Element
                                     (Constant_Pool_Index'Input (Attribute_Stream))),

                              Descriptor_Ref         =>
                                Utf_8_Constant_Pool_Entry
                                  (Pool.Element
                                     (Constant_Pool_Index'Input (Attribute_Stream))),
                              Frame_Index            =>
                                u2.Big_Endian'Input (Attribute_Stream)));
                     end loop;
                     Item.Append (Class_File_Attribute'
                        (Attribute_Type       => LocalVariableTable,
                        Name_Ref              => Name,
                        Local_Variable_Table  => Local_Variable_Vector));
                  end;

               when LocalVariableTypeTable =>
                  declare
                     New_Entry : Class_File_Attribute :=
                        (Attribute_Type => LocalVariableTypeTable,
                        Name_Ref       => Name,
                        others         => <>);
                  begin
                     for Index in 1 .. u2.Big_Endian'Input (Attribute_Stream) loop
                        New_Entry.Local_Variable_Type_Table.Append
                           (CFA_LocalVariableTypeTable_Variable_Entry'
                              (Program_Counter_Start  =>
                                 u2.Big_Endian'Input (Attribute_Stream),
                              Program_Counter_Length =>
                                 u2.Big_Endian'Input (Attribute_Stream),
                              Name_Ref               =>
                                 Utf_8_Constant_Pool_Entry
                                    (Pool.Element
                                       (Constant_Pool_Index'Input (Attribute_Stream))),

                              Signature_Ref          =>
                                 Utf_8_Constant_Pool_Entry
                                    (Pool.Element
                                       (Constant_Pool_Index'Input (Attribute_Stream))),
                              Frame_Index            =>
                                 u2.Big_Endian'Input (Attribute_Stream)));
                     end loop;
                     Item.Append (New_Entry);
                  end;

               when Deprecated =>
                  Item.Append
                     (Class_File_Attribute'
                        (Attribute_Type => Deprecated, Name_Ref => Name));

               when RuntimeVisibleAnnotations | RuntimeInvisibleAnnotations =>
                  declare
                     Vector : CFA_Annotation_Vectors.Vector;
                  begin
                     for Index in 1 .. u2.Big_Endian'Input (Attribute_Stream) loop
                        Vector.Append (Read_Annotation);
                     end loop;
                     case Attribute_Type is
                        when RuntimeVisibleAnnotations =>
                           Item.Append
                              (Class_File_Attribute'
                                 (Attribute_Type              =>
                                    RuntimeVisibleAnnotations,
                                 Name_Ref                    => Name,
                                 Runtime_Visible_Annotations => Vector));

                        when RuntimeInvisibleAnnotations =>
                           Item.Append
                              (Class_File_Attribute'
                                 (Attribute_Type                =>
                                    RuntimeInvisibleAnnotations,
                                 Name_Ref                      => Name,
                                 Runtime_Invisible_Annotations => Vector));

                        when others =>
                           raise Impossible_Branch;
                     end case;
                  end;

               when RuntimeVisibleParameterAnnotations
                  | RuntimeInvisibleParameterAnnotations
               =>
                  declare
                     Vector : CFA_Parameter_Annotation_Vectors.Vector;
                  begin
                     for Index in 1 .. Byteflippers.Unsigned_8'Input (Attribute_Stream) loop
                        declare
                           New_Annotation_Block : CFA_Annotation_Vectors.Vector;
                        begin
                           for Annotation_Index
                              in 1 .. u2.Big_Endian'Input (Attribute_Stream)
                           loop
                              New_Annotation_Block.Append (Read_Annotation);
                           end loop;
                           Vector.Append (New_Annotation_Block);
                        end;
                     end loop;
                     case Attribute_Type is
                        when RuntimeVisibleParameterAnnotations =>
                           Item.Append
                              (Class_File_Attribute'
                                 (Attribute_Type                        =>
                                    RuntimeVisibleParameterAnnotations,
                                 Name_Ref                              => Name,
                                 Runtime_Visible_Parameter_Annotations =>
                                    Vector));

                        when RuntimeInvisibleParameterAnnotations =>
                           Item.Append
                              (Class_File_Attribute'
                                 (Attribute_Type                          =>
                                    RuntimeInvisibleParameterAnnotations,
                                 Name_Ref                                => Name,
                                 Runtime_Invisible_Parameter_Annotations =>
                                    Vector));

                        when others =>
                           raise Impossible_Branch;
                     end case;
                  end;

               when AnnotationDefault =>
                  Item.Append
                     (Class_File_Attribute'
                        (Attribute_Type => AnnotationDefault,
                        Name_Ref       => Name,
                        Default_Value  =>
                           new CFA_Annotation_Element_Value'(Read_Element_Value)));

               when BootstrapMethods =>
                  declare
                     New_Entry : Class_File_Attribute :=
                        Class_File_Attribute'
                           (Attribute_Type => BootstrapMethods,
                           Name_Ref       => Name,
                           others         => <>);
                  begin
                     for Index in 1 .. u2.Big_Endian'Input (Attribute_Stream) loop
                        declare
                           New_Method : CFA_BootstrapMethods_Method_Entry :=
                              CFA_BootstrapMethods_Method_Entry'
                                 (Method_Ref =>
                                    Method_Handle_Constant_Pool_Entry
                                    (Pool.Element
                                       (Constant_Pool_Index
                                          (u2.Big_Endian'Input (Attribute_Stream)))),
                                 others     => <>);
                        begin
                           for Argument_Index in 1 .. u2.Big_Endian'Input (Attribute_Stream)
                           loop
                              New_Method.Method_Arguments.Append
                                 (Pool.Element
                                    (Constant_Pool_Index
                                       (u2.Big_Endian'Input (Attribute_Stream))));
                           end loop;
                           New_Entry.Bootstrap_Methods.Append (New_Method);
                        end;
                     end loop;
                     Item.Append (New_Entry);
                  end;

               when Other | SourceDebugExtension =>
                  case Attribute_Type is
                     when Other =>
                        Item.Append
                           (Class_File_Attribute'
                              (Attribute_Type => Other,
                              Name_Ref       => Name,
                              Data           => new Octet_Memory_Stream.Octet_Array'(Data)));
                        raise Program_Error with Name.Utf_Bytes.all'Image;

                     when SourceDebugExtension =>
                        Item.Append
                           (Class_File_Attribute'
                              (Attribute_Type  => SourceDebugExtension,
                              Name_Ref        => Name,
                              Debug_Extension => new Octet_Memory_Stream.Octet_Array'(Data)));

                     when others =>
                        raise Impossible_Branch;
                  end case;
            end case;
         end;
      end;
   end loop;
end Read_Attribute_Vector;
