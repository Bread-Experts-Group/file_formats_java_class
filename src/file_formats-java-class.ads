with Ada.Containers.Indefinite_Ordered_Maps;
with Ada.Containers.Indefinite_Vectors;
with Ada.Containers.Vectors;
with Ada.Streams;
with Byteflippers;

package File_Formats.Java.Class is

   package u8 renames Byteflippers.Endians_Unsigned_64;
   package u4 renames Byteflippers.Endians_Unsigned_32;
   package u2 renames Byteflippers.Endians_Unsigned_16;

   package i8 renames Byteflippers.Endians_Signed_64;
   package i4 renames Byteflippers.Endians_Signed_32;
   package i2 renames Byteflippers.Endians_Signed_16;

   ------------------------------
   -- Class File Constant Pool --
   ------------------------------

   type Constant_Pool_Entry_Tag is
     (UTF_8,
      INTEGER,
      FLOAT,
      LONG,
      DOUBLE,
      CLASS,
      STRING,
      FIELD_REFERENCE,
      METHOD_REFERENCE,
      INTERFACE_METHOD_REFERENCE,
      NAME_AND_TYPE,
      METHOD_HANDLE,
      METHOD_TYPE,
      INVOKE_DYNAMIC)
   with Size => 8;

   for Constant_Pool_Entry_Tag use
     (UTF_8                      => 1,
      INTEGER                    => 3,
      FLOAT                      => 4,
      LONG                       => 5,
      DOUBLE                     => 6,
      CLASS                      => 7,
      STRING                     => 8,
      FIELD_REFERENCE            => 9,
      METHOD_REFERENCE           => 10,
      INTERFACE_METHOD_REFERENCE => 11,
      NAME_AND_TYPE              => 12,
      METHOD_HANDLE              => 15,
      METHOD_TYPE                => 16,
      INVOKE_DYNAMIC             => 18);

   use type u2.Big_Endian;

   subtype Class_Utf_8_String is Standard.String
   with Predicate => Class_Utf_8_String'Length <= u2.Big_Endian'Last;

   type Class_Utf_8_String_Access is not null access Class_Utf_8_String;

   type Constant_Pool_Entry;
   type Class_Constant_Pool_Entry;
   type Utf_8_Constant_Pool_Entry;
   type Name_And_Type_Constant_Pool_Entry;

   type Constant_Pool_Entry_Access is not null access Constant_Pool_Entry;
   type Utf_8_Constant_Pool_Entry_Access is
     not null access Utf_8_Constant_Pool_Entry;
   type Utf_8_Constant_Pool_Entry_Access_Optional is
     access Utf_8_Constant_Pool_Entry;
   type Class_Constant_Pool_Entry_Access is
     not null access Class_Constant_Pool_Entry;
   type Class_Constant_Pool_Entry_Access_Optional is
     access Class_Constant_Pool_Entry;
   type Name_And_Type_Constant_Pool_Entry_Access is
     not null access Name_And_Type_Constant_Pool_Entry;
   type Name_And_Type_Constant_Pool_Entry_Access_Optional is
     access Name_And_Type_Constant_Pool_Entry;

   type Method_Handle_Reference_Kind is
     (REF_GET_FIELD,
      REF_GET_STATIC,
      REF_PUT_FIELD,
      REF_PUT_STATIC,
      REF_INVOKE_VIRTUAL,
      REF_INVOKE_STATIC,
      REF_INVOKE_SPECIAL,
      REF_NEW_INVOKE_SPECIAL,
      REF_INVOKE_INTERFACE)
   with Size => 8;

   for Method_Handle_Reference_Kind use
     (REF_GET_FIELD          => 1,
      REF_GET_STATIC         => 2,
      REF_PUT_FIELD          => 3,
      REF_PUT_STATIC         => 4,
      REF_INVOKE_VIRTUAL     => 5,
      REF_INVOKE_STATIC      => 6,
      REF_INVOKE_SPECIAL     => 7,
      REF_NEW_INVOKE_SPECIAL => 8,
      REF_INVOKE_INTERFACE   => 9);

   type Constant_Pool_Entry (Tag : Constant_Pool_Entry_Tag) is record
      case Tag is
         when UTF_8 =>
            Utf_Bytes : Class_Utf_8_String_Access;

         when INTEGER =>
            Int_Bytes : Standard.Integer;

         when FLOAT =>
            Float_Bytes : Standard.Float;

         when LONG =>
            Long_Bytes : i8.Big_Endian;

         when DOUBLE =>
            Double_Bytes : Standard.Long_Float;

         when CLASS =>
            Qualified_Name_Ref : Utf_8_Constant_Pool_Entry_Access;

         when STRING =>
            String_Ref : Utf_8_Constant_Pool_Entry_Access;

         when FIELD_REFERENCE
               | METHOD_REFERENCE
               | INTERFACE_METHOD_REFERENCE =>
            Class_Ref         : Class_Constant_Pool_Entry_Access;
            Name_And_Type_Ref : Name_And_Type_Constant_Pool_Entry_Access;

         when NAME_AND_TYPE =>
            Name_Ref, Descriptor_Ref : Utf_8_Constant_Pool_Entry_Access;

         when METHOD_HANDLE =>
            Reference_Kind : Method_Handle_Reference_Kind;
            Reference_Ref  : Constant_Pool_Entry_Access;

         when METHOD_TYPE =>
            Method_Descriptor_Ref : Utf_8_Constant_Pool_Entry_Access;

         when INVOKE_DYNAMIC =>
            Bootstrap_Method_Index   : u2.Big_Endian;
            Method_Name_And_Type_Ref :
              Name_And_Type_Constant_Pool_Entry_Access;
      end case;
   end record;

   subtype Constant_Pool_Index is i2.Big_Endian range 1 .. i2.Big_Endian'Last;
   use type i2.Big_Endian;

   package Constant_Pool_Maps is new
     Ada.Containers.Indefinite_Ordered_Maps
       (Constant_Pool_Index,
        Constant_Pool_Entry);

   procedure Read_Constant_Pool_Map
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Constant_Pool_Maps.Map);

   procedure Write_Constant_Pool_Map
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Constant_Pool_Maps.Map);

   type Utf_8_Constant_Pool_Entry is new Constant_Pool_Entry (UTF_8);
   type Class_Constant_Pool_Entry is new Constant_Pool_Entry (CLASS);
   type Name_And_Type_Constant_Pool_Entry is
     new Constant_Pool_Entry (NAME_AND_TYPE);
   type Method_Handle_Constant_Pool_Entry is
     new Constant_Pool_Entry (METHOD_HANDLE);

   type Class_File_Access_Flags is record
      PUBLIC       : Boolean;
      FINAL        : Boolean;
      SUPER        : Boolean;
      IS_INTERFACE : Boolean;
      IS_ABSTRACT  : Boolean;
      SYNTHETIC    : Boolean;
      ANNOTATION   : Boolean;
      ENUM         : Boolean;
   end record
   with
     Size => 16,
     Predicate =>
       not (Class_File_Access_Flags.IS_INTERFACE
            and then Class_File_Access_Flags.FINAL);

   for Class_File_Access_Flags use
     record
       PUBLIC at 0 range 0 .. 0;
       FINAL at 0 range 4 .. 4;
       SUPER at 0 range 5 .. 5;
       IS_INTERFACE at 1 range 1 .. 1;
       IS_ABSTRACT at 1 range 2 .. 2;
       SYNTHETIC at 1 range 4 .. 4;
       ANNOTATION at 1 range 5 .. 5;
       ENUM at 1 range 6 .. 6;
     end record;

   --  NOTE: .Vectors would be preferred here, however it causes an access
   --        error (probably due to the empty class spaces being filled,
   --        and due to the class entry specification requiring a not null
   --        access... yeah.)
   package Interface_Vectors is new
     Ada.Containers.Indefinite_Vectors (Positive, Class_Constant_Pool_Entry);

   type Class_File_Environment is (CLASS, IS_INTERFACE);

   ---------------------------
   -- Class File Attributes --
   ---------------------------

   type Class_File_Attribute_Type is
     (ConstantValue,
      Code,
      StackMapTable,
      Exceptions,
      InnerClasses,
      EnclosingMethod,
      Synthetic,
      Signature,
      SourceFile,
      SourceDebugExtension,
      LineNumberTable,
      LocalVariableTable,
      LocalVariableTypeTable,
      Deprecated,
      RuntimeVisibleAnnotations,
      RuntimeInvisibleAnnotations,
      RuntimeVisibleParameterAnnotations,
      RuntimeInvisibleParameterAnnotations,
      AnnotationDefault,
      BootstrapMethods,
      Other);

   type Raw_Data is array (u4.Big_Endian range <>) of Byteflippers.Unsigned_8;
   type Raw_Data_Access is not null access Raw_Data;

   type Positive_u4 is new u4.Big_Endian range 1 .. u4.Big_Endian'Last;
   type Raw_Data_Filled is
     array (Positive_u4 range <>) of Byteflippers.Unsigned_8;
   type Raw_Data_Filled_Access is not null access Raw_Data_Filled;

   type CFA_Code_Exception_Entry is record
      Program_Counter_Start   : u2.Big_Endian;
      Program_Counter_Stop    : u2.Big_Endian;
      Program_Counter_Handler : u2.Big_Endian;
      Catch                   : Class_Constant_Pool_Entry_Access_Optional;
   end record;

   package CFA_Code_Exception_Vectors is new
     Ada.Containers.Vectors (Positive, CFA_Code_Exception_Entry);
   type Attribute_Vector;
   type Attribute_Vector_Access is not null access Attribute_Vector;

   type CFA_SMT_Variable_Tag is
     (ITEM_TOP,
      ITEM_INTEGER,
      ITEM_FLOAT,
      ITEM_DOUBLE,
      ITEM_LONG,
      ITEM_NULL,
      ITEM_UNINITIALIZED_THIS,
      ITEM_OBJECT,
      ITEM_UNINTIALIZED)
   with Size => 8;

   for CFA_SMT_Variable_Tag use
     (ITEM_TOP                => 0,
      ITEM_INTEGER            => 1,
      ITEM_FLOAT              => 2,
      ITEM_DOUBLE             => 3,
      ITEM_LONG               => 4,
      ITEM_NULL               => 5,
      ITEM_UNINITIALIZED_THIS => 6,
      ITEM_OBJECT             => 7,
      ITEM_UNINTIALIZED       => 8);

   type CFA_SMT_Verification_Type_Info (Tag : CFA_SMT_Variable_Tag) is record
      case Tag is
         when ITEM_TOP
               | ITEM_INTEGER
               | ITEM_FLOAT
               | ITEM_DOUBLE
               | ITEM_LONG
               | ITEM_NULL
               | ITEM_UNINITIALIZED_THIS =>
            null;

         when ITEM_OBJECT =>
            Instance_Of_Ref : Class_Constant_Pool_Entry;

         when ITEM_UNINTIALIZED =>
            Code_Offset : u2.Big_Endian;
      end case;
   end record;

   type CFA_SMT_Verification_Type_Info_Access is
     not null access CFA_SMT_Verification_Type_Info;

   package CFA_SMT_Verification_Type_Info_Vectors is new
     Ada.Containers.Indefinite_Vectors
       (Positive,
        CFA_SMT_Verification_Type_Info);

   type CFA_StackMapTable_Type is
     (SAME,
      SAME_LOCALS_1_STACK_ITEM,
      RESERVED,
      SAME_LOCALS_1_STACK_ITEM_EXTENDED,
      CHOP,
      SAME_FRAME_EXTENDED,
      APPEND,
      FULL_FRAME);

   type CFA_StackMapTable_Frame (Frame_Type : CFA_StackMapTable_Type) is record
      Offset_Delta : u2.Big_Endian;
      case Frame_Type is
         when SAME =>
            null;

         when SAME_LOCALS_1_STACK_ITEM =>
            SL1_Stack_Item : CFA_SMT_Verification_Type_Info_Access;

         when RESERVED =>
            null;

         when SAME_LOCALS_1_STACK_ITEM_EXTENDED =>
            SL1E_Stack_Item : CFA_SMT_Verification_Type_Info_Access;

         when CHOP =>
            null;

         when SAME_FRAME_EXTENDED =>
            null;

         when APPEND =>
            APPEND_Stack : CFA_SMT_Verification_Type_Info_Vectors.Vector;

         when FULL_FRAME =>
            FF_Locals : CFA_SMT_Verification_Type_Info_Vectors.Vector;
            FF_Stack  : CFA_SMT_Verification_Type_Info_Vectors.Vector;
      end case;
   end record;

   package CFA_StackMapTable_Frame_Vectors is new
     Ada.Containers.Indefinite_Vectors (Positive, CFA_StackMapTable_Frame);

   type CFA_InnerClasses_Access_Flags is record
      PUBLIC       : Boolean;
      IS_PRIVATE   : Boolean;
      IS_PROTECTED : Boolean;
      STATIC       : Boolean;
      FINAL        : Boolean;
      IS_INTERFACE : Boolean;
      IS_ABSTRACT  : Boolean;
      SYNTHETIC    : Boolean;
      ANNOTATION   : Boolean;
      ENUM         : Boolean;
   end record
   with Size => 16;

   for CFA_InnerClasses_Access_Flags use
     record
       PUBLIC at 0 range 0 .. 0;
       IS_PRIVATE at 0 range 1 .. 1;
       IS_PROTECTED at 0 range 2 .. 2;
       STATIC at 0 range 3 .. 3;
       FINAL at 0 range 4 .. 4;
       IS_INTERFACE at 1 range 1 .. 1;
       IS_ABSTRACT at 1 range 2 .. 2;
       SYNTHETIC at 1 range 4 .. 4;
       ANNOTATION at 1 range 5 .. 5;
       ENUM at 1 range 6 .. 6;
     end record;

   type CFA_InnerClasses_Class_Entry is record
      Inner_Class, Outer_Class : Class_Constant_Pool_Entry_Access_Optional;
      Inner_Class_Name         : Utf_8_Constant_Pool_Entry_Access_Optional;
      Inner_Class_Access       : CFA_InnerClasses_Access_Flags;
   end record;

   type CFA_LineNumberTable_Line_Entry is record
      Program_Counter_Start : u2.Big_Endian;
      Line_Number           : u2.Big_Endian;
   end record;

   type CFA_LocalVariableTable_Variable_Entry is record
      Program_Counter_Start    : u2.Big_Endian;
      Program_Counter_Length   : u2.Big_Endian;
      Name_Ref, Descriptor_Ref : Utf_8_Constant_Pool_Entry;
      Frame_Index              : u2.Big_Endian;
   end record;

   type CFA_LocalVariableTypeTable_Variable_Entry is record
      Program_Counter_Start   : u2.Big_Endian;
      Program_Counter_Length  : u2.Big_Endian;
      Name_Ref, Signature_Ref : Utf_8_Constant_Pool_Entry;
      Frame_Index             : u2.Big_Endian;
   end record;

   package Constant_Pool_Entry_Vectors is new
     Ada.Containers.Indefinite_Vectors (Positive, Constant_Pool_Entry);

   type CFA_Annotation;
   type CFA_Annotation_Access is not null access CFA_Annotation;

   type CFA_Annotation_Element_Value_Vector;
   type CFA_Annotation_Element_Value_Vector_Access is
     not null access CFA_Annotation_Element_Value_Vector;

   type CFA_Annotation_Element_Value (Tag : Character) is record
      case Tag is
         when 'B' | 'C' | 'D' | 'F' | 'I' | 'J' | 'S' | 'Z' | 's' =>
            Constant_Value : Constant_Pool_Entry_Access;

         when 'e' =>
            Field_Descriptor   : Utf_8_Constant_Pool_Entry;
            Enum_Constant_Name : Utf_8_Constant_Pool_Entry;

         when 'c' =>
            Return_Descriptor : Utf_8_Constant_Pool_Entry;

         when '@' =>
            Annotation : CFA_Annotation_Access;

         when '[' =>
            Element_Values : CFA_Annotation_Element_Value_Vector_Access;

         when others =>
            null;
      end case;
   end record;

   type CFA_Annotation_Element_Value_Access is
     not null access CFA_Annotation_Element_Value;

   type CFA_Annotation_Element_Value_Pair is record
      Element_Name  : Utf_8_Constant_Pool_Entry;
      Element_Value : CFA_Annotation_Element_Value_Access;
   end record;

   package CFA_Annotation_Element_Value_Vectors is new
     Ada.Containers.Indefinite_Vectors
       (Positive,
        CFA_Annotation_Element_Value);

   package CFA_Annotation_Element_Value_Pair_Vectors is new
     Ada.Containers.Indefinite_Vectors
       (Positive,
        CFA_Annotation_Element_Value_Pair);

   type CFA_Annotation_Element_Value_Vector is
     new CFA_Annotation_Element_Value_Vectors.Vector
   with null record;

   type CFA_Annotation is record
      Field_Descriptor    : Utf_8_Constant_Pool_Entry;
      Element_Value_Pairs : CFA_Annotation_Element_Value_Pair_Vectors.Vector;
   end record;

   type CFA_BootstrapMethods_Method_Entry is record
      Method_Ref       : Method_Handle_Constant_Pool_Entry;
      Method_Arguments : Constant_Pool_Entry_Vectors.Vector;
   end record;

   package CFA_InnerClasses_Class_Vectors is new
     Ada.Containers.Vectors (Positive, CFA_InnerClasses_Class_Entry);

   package CFA_LineNumberTable_Line_Vectors is new
     Ada.Containers.Vectors (Positive, CFA_LineNumberTable_Line_Entry);

   package CFA_LocalVariableTable_Variable_Vectors is new
     Ada.Containers.Vectors (Positive, CFA_LocalVariableTable_Variable_Entry);

   package CFA_LocalVariableTypeTable_Variable_Vectors is new
     Ada.Containers.Vectors
       (Positive,
        CFA_LocalVariableTypeTable_Variable_Entry);

   package CFA_Annotation_Vectors is new
     Ada.Containers.Indefinite_Vectors (Positive, CFA_Annotation);

   package CFA_Parameter_Annotation_Vectors is new
     Ada.Containers.Vectors
       (Positive,
        CFA_Annotation_Vectors.Vector,
        CFA_Annotation_Vectors."=");

   package CFA_BootstrapMethods_Method_Vectors is new
     Ada.Containers.Vectors (Positive, CFA_BootstrapMethods_Method_Entry);

   package Class_Vectors is new
     Ada.Containers.Indefinite_Vectors (Positive, Class_Constant_Pool_Entry);

   type Class_File_Attribute (Attribute_Type : Class_File_Attribute_Type) is
   record
      Name_Ref : Utf_8_Constant_Pool_Entry;
      case Attribute_Type is
         when SourceFile =>
            Source_File : Utf_8_Constant_Pool_Entry;

         when ConstantValue =>
            Constant_Value : Constant_Pool_Entry_Access;

         when Code =>
            Max_Stack_Size       : u2.Big_Endian;
            Local_Variable_Count : u2.Big_Endian;
            Code                 : Raw_Data_Filled_Access;
            Exception_Table      : CFA_Code_Exception_Vectors.Vector;
            Attributes           : Attribute_Vector_Access;

         when StackMapTable =>
            Stack_Map_Table : CFA_StackMapTable_Frame_Vectors.Vector;

         when Exceptions =>
            Exceptions_Table : Class_Vectors.Vector;

         when InnerClasses =>
            Inner_Classes : CFA_InnerClasses_Class_Vectors.Vector;

         when EnclosingMethod =>
            Enclosing_Class  : Class_Constant_Pool_Entry;
            Enclosing_Method :
              Name_And_Type_Constant_Pool_Entry_Access_Optional;

         when Synthetic | Deprecated =>
            null;

         when Signature =>
            Generic_Signature : Utf_8_Constant_Pool_Entry;

         when SourceDebugExtension =>
            Debug_Extension : Raw_Data_Access;

         when LineNumberTable =>
            Line_Number_Table : CFA_LineNumberTable_Line_Vectors.Vector;

         when LocalVariableTable =>
            Local_Variable_Table :
              CFA_LocalVariableTable_Variable_Vectors.Vector;

         when LocalVariableTypeTable =>
            Local_Variable_Type_Table :
              CFA_LocalVariableTypeTable_Variable_Vectors.Vector;

         when RuntimeVisibleAnnotations =>
            Runtime_Visible_Annotations : CFA_Annotation_Vectors.Vector;

         when RuntimeInvisibleAnnotations =>
            Runtime_Invisible_Annotations : CFA_Annotation_Vectors.Vector;

         when RuntimeVisibleParameterAnnotations =>
            Runtime_Visible_Parameter_Annotations :
              CFA_Parameter_Annotation_Vectors.Vector;

         when RuntimeInvisibleParameterAnnotations =>
            Runtime_Invisible_Parameter_Annotations :
              CFA_Parameter_Annotation_Vectors.Vector;

         when AnnotationDefault =>
            Default_Value : CFA_Annotation_Element_Value_Access;

         when BootstrapMethods =>
            Bootstrap_Methods : CFA_BootstrapMethods_Method_Vectors.Vector;

         when Other =>
            Data : Raw_Data_Access;
      end case;
   end record;

   package Attribute_Vectors is new
     Ada.Containers.Indefinite_Vectors (Positive, Class_File_Attribute);
   type Attribute_Vector is new Attribute_Vectors.Vector with null record;

   procedure Read_Attribute_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Attribute_Vectors.Vector'Class;
      Pool   : Constant_Pool_Maps.Map);

   procedure Write_Attribute_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Attribute_Vectors.Vector);

   -----------------------
   -- Class File Fields --
   -----------------------

   type Class_File_Field_Access_Flags is record
      PUBLIC       : Boolean;
      IS_PRIVATE   : Boolean;
      IS_PROTECTED : Boolean;
      STATIC       : Boolean;
      FINAL        : Boolean;
      VOLATILE     : Boolean;
      TRANSIENT    : Boolean;
      SYNTHETIC    : Boolean;
      ENUM         : Boolean;
   end record
   with Size => 16;

   for Class_File_Field_Access_Flags use
     record
       PUBLIC at 0 range 0 .. 0;
       IS_PRIVATE at 0 range 1 .. 1;
       IS_PROTECTED at 0 range 2 .. 2;
       STATIC at 0 range 3 .. 3;
       FINAL at 0 range 4 .. 4;
       VOLATILE at 0 range 6 .. 6;
       TRANSIENT at 0 range 7 .. 7;
       SYNTHETIC at 1 range 4 .. 4;
       ENUM at 1 range 6 .. 6;
     end record;

   type Class_File_Field_Access_Flags_Any is new Class_File_Field_Access_Flags
   with
     Predicate =>
       not (Class_File_Field_Access_Flags_Any.IS_PRIVATE
            or else Class_File_Field_Access_Flags_Any.IS_PROTECTED
            or else Class_File_Field_Access_Flags_Any.VOLATILE
            or else Class_File_Field_Access_Flags_Any.TRANSIENT);

   type Class_File_Field (Environment : Class_File_Environment) is record
      Name_Ref, Descriptor_Ref : Utf_8_Constant_Pool_Entry;
      Attributes               : Attribute_Vectors.Vector;
      case Environment is
         when CLASS =>
            Access_Flags_Class : Class_File_Field_Access_Flags;

         when IS_INTERFACE =>
            Access_Flags_Others : Class_File_Field_Access_Flags_Any;
      end case;
   end record;

   package Field_Vectors is new
     Ada.Containers.Indefinite_Vectors (Positive, Class_File_Field);

   procedure Read_Field_Vector
     (Stream      : not null access Ada.Streams.Root_Stream_Type'Class;
      Item        : out Field_Vectors.Vector;
      Pool        : Constant_Pool_Maps.Map;
      Environment : Class_File_Environment);

   procedure Write_Field_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Field_Vectors.Vector);

   ------------------------
   -- Class File Methods --
   ------------------------

   type Class_File_Method_Access_Flags is record
      PUBLIC          : Boolean;
      IS_PRIVATE      : Boolean;
      IS_PROTECTED    : Boolean;
      STATIC          : Boolean;
      FINAL           : Boolean;
      IS_SYNCHRONIZED : Boolean;
      BRIDGE          : Boolean;
      VARARGS         : Boolean;
      NATIVE          : Boolean;
      IS_ABSTRACT     : Boolean;
      STRICT          : Boolean;
      SYNTHETIC       : Boolean;
   end record
   with Size => 16;

   for Class_File_Method_Access_Flags use
     record
       PUBLIC at 0 range 0 .. 0;
       IS_PRIVATE at 0 range 1 .. 1;
       IS_PROTECTED at 0 range 2 .. 2;
       STATIC at 0 range 3 .. 3;
       FINAL at 0 range 4 .. 4;
       IS_SYNCHRONIZED at 0 range 5 .. 5;
       BRIDGE at 0 range 6 .. 6;
       VARARGS at 0 range 7 .. 7;
       NATIVE at 1 range 0 .. 0;
       IS_ABSTRACT at 1 range 2 .. 2;
       STRICT at 1 range 3 .. 3;
       SYNTHETIC at 1 range 4 .. 4;
     end record;

   type Class_File_Method_Access_Flags_Any is
     new Class_File_Method_Access_Flags
   with
     Predicate =>
       not (Class_File_Method_Access_Flags_Any.IS_PRIVATE
            or else Class_File_Method_Access_Flags_Any.IS_PROTECTED
            or else Class_File_Method_Access_Flags_Any.STATIC
            or else Class_File_Method_Access_Flags_Any.FINAL
            or else Class_File_Method_Access_Flags_Any.IS_SYNCHRONIZED
            or else Class_File_Method_Access_Flags_Any.NATIVE);

   type Class_File_Method (Environment : Class_File_Environment) is record
      Name_Ref, Descriptor_Ref : Utf_8_Constant_Pool_Entry;
      Attributes               : Attribute_Vectors.Vector;
      case Environment is
         when CLASS =>
            Access_Flags_Class : Class_File_Method_Access_Flags;

         when IS_INTERFACE =>
            Access_Flags_Others : Class_File_Method_Access_Flags_Any;
      end case;
   end record;

   package Method_Vectors is new
     Ada.Containers.Indefinite_Vectors (Positive, Class_File_Method);

   procedure Read_Method_Vector
     (Stream      : not null access Ada.Streams.Root_Stream_Type'Class;
      Item        : out Method_Vectors.Vector;
      Pool        : Constant_Pool_Maps.Map;
      Environment : Class_File_Environment);

   procedure Write_Method_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Method_Vectors.Vector);

   ----------------
   -- Class File --
   ----------------

   type Class_File_Magic is
     new u4.Big_Endian range 16#CAFEBABE# .. 16#CAFEBABE#;

   type Class_File is record
      Magic         : Class_File_Magic;
      Minor_Version : u2.Big_Endian;
      Major_Version : u2.Big_Endian;
      Constant_Pool : Constant_Pool_Maps.Map;
      Access_Flags  : Class_File_Access_Flags;
      This_Class    : Class_Constant_Pool_Entry_Access;
      Super_Class   : Class_Constant_Pool_Entry_Access_Optional;
      Interfaces    : Interface_Vectors.Vector;
      Fields        : Field_Vectors.Vector;
      Methods       : Method_Vectors.Vector;
      Attributes    : Attribute_Vectors.Vector;
   end record;

   function Read_Class_File
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class)
      return Class_File;

   procedure Write_Class_File
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Class_File);

   for Class_File'Input use Read_Class_File;
   for Class_File'Write use Write_Class_File;

end File_Formats.Java.Class;
