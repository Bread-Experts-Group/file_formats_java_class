with Ada.Containers.Indefinite_Vectors;
with Ada.Containers.Vectors;
with Ada.Streams;
with Byteflippers;

package File_Formats.Java.Class is

   package u4 renames Byteflippers.Endians_Unsigned_32;
   package u2 renames Byteflippers.Endians_Unsigned_16;

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
      NAME_AND_TYPE) with Size => 8;

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
      NAME_AND_TYPE              => 12);

   use type u2.Big_Endian;

   subtype Class_Utf_8_String is Standard.String
      with Predicate => Class_Utf_8_String'Length <= u2.Big_Endian'Last;

   type Class_Constant_Pool_Entry;
   type Utf_8_Constant_Pool_Entry;
   type Name_And_Type_Constant_Pool_Entry;

   type Constant_Pool_Entry (Tag : Constant_Pool_Entry_Tag) is record
      case Tag is
         when UTF_8 =>
            Utf_Bytes : not null access Class_Utf_8_String;
         when INTEGER =>
            Int_Bytes : Standard.Integer;
         when FLOAT =>
            Float_Bytes : Standard.Float;
         when LONG =>
            Long_Bytes : Standard.Long_Integer;
         when DOUBLE =>
            Double_Bytes : Standard.Long_Float;
         when CLASS =>
            Qualified_Name_Ref : not null access Utf_8_Constant_Pool_Entry;
         when STRING =>
            String_Ref : not null access Utf_8_Constant_Pool_Entry;
         when FIELD_REFERENCE  |
              METHOD_REFERENCE |
              INTERFACE_METHOD_REFERENCE =>
            Class_Ref         :
               not null access Class_Constant_Pool_Entry;
            Name_And_Type_Ref :
               not null access Name_And_Type_Constant_Pool_Entry;
         when NAME_AND_TYPE =>
            Name_Ref, Descriptor_Ref :
               not null access Utf_8_Constant_Pool_Entry;
      end case;
   end record;

   function Read_Constant_Pool_Entry
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class)
   return Constant_Pool_Entry;

   procedure Write_Constant_Pool_Entry
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Constant_Pool_Entry);

   for Constant_Pool_Entry'Input use Read_Constant_Pool_Entry;
   for Constant_Pool_Entry'Write use Write_Constant_Pool_Entry;

   package Constant_Pool_Vectors is new
      Ada.Containers.Indefinite_Vectors (Positive, Constant_Pool_Entry);

   procedure Read_Constant_Pool_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Constant_Pool_Vectors.Vector);

   procedure Write_Constant_Pool_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Constant_Pool_Vectors.Vector);

   type Utf_8_Constant_Pool_Entry is
      new Constant_Pool_Entry (UTF_8);
   type Class_Constant_Pool_Entry is
      new Constant_Pool_Entry (CLASS);
   type Name_And_Type_Constant_Pool_Entry is
      new Constant_Pool_Entry (NAME_AND_TYPE);

   type Utf_8_Constant_Pool_Entry_Access is
      not null access Utf_8_Constant_Pool_Entry;
   type Class_Constant_Pool_Entry_Access is
      not null access Class_Constant_Pool_Entry;
   type Class_Constant_Pool_Entry_Access_Optional is
      access Class_Constant_Pool_Entry;

   type Class_File_Access is
     (PUBLIC,
      FINAL,
      SUPER,
      IS_INTERFACE,
      IS_ABSTRACT) with Size => 16;

   for Class_File_Access use
     (PUBLIC       => 2 ** 0,
      FINAL        => 2 ** 4,
      SUPER        => 2 ** 5,
      IS_INTERFACE => 2 ** 9,
      IS_ABSTRACT  => 2 ** 10);

   type Class_File_Access_Flags is
      array (Class_File_Access'First .. Class_File_Access'Last)
      of Boolean with
         Component_Size => 1,
         Predicate =>
            not (Class_File_Access_Flags (IS_INTERFACE) and then
                 Class_File_Access_Flags (FINAL));

   package Interface_Vectors is new
      Ada.Containers.Vectors (Positive,
                              Class_Constant_Pool_Entry_Access_Optional);

   type Class_File_Environment is
     (CLASS,
      INSTANCE,
      IS_INTERFACE);

   ---------------------------
   -- Class File Attributes --
   ---------------------------

   type Class_File_Attribute_Type is
     (SourceFile,
      ConstantValue,
      Code,
      Exceptions,
      LineNumberTable,
      LocalVariableTable,
      Other);

   type Class_File_Attribute (Attribute_Type : Class_File_Attribute_Type)
   is record
      Name_Ref : Utf_8_Constant_Pool_Entry_Access;
   end record;

   function Read_Class_File_Attribute
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class)
   return Class_File_Attribute;

   procedure Write_Class_File_Attribute
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Class_File_Attribute);

   for Class_File_Attribute'Input use Read_Class_File_Attribute;
   for Class_File_Attribute'Write use Write_Class_File_Attribute;

   package Attribute_Vectors is new
      Ada.Containers.Indefinite_Vectors (Positive, Class_File_Attribute);

   procedure Read_Attribute_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Attribute_Vectors.Vector);

   procedure Write_Attribute_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Attribute_Vectors.Vector);

   -----------------------
   -- Class File Fields --
   -----------------------

   type Class_File_Field_Access is
     (PUBLIC,
      IS_PRIVATE,
      IS_PROTECTED,
      STATIC,
      FINAL,
      VOLATILE,
      TRANSIENT) with Size => 16;

   for Class_File_Field_Access use
     (PUBLIC       => 2 ** 0,
      IS_PRIVATE   => 2 ** 1,
      IS_PROTECTED => 2 ** 2,
      STATIC       => 2 ** 3,
      FINAL        => 2 ** 4,
      VOLATILE     => 2 ** 6,
      TRANSIENT    => 2 ** 7);

   type Class_File_Field_Access_Flags is
      array (Class_File_Field_Access'First .. Class_File_Field_Access'Last)
      of Boolean with Component_Size => 1;

   type Class_File_Field_Access_Flags_Any is
      new Class_File_Field_Access_Flags
      with Predicate =>
         not (Class_File_Field_Access_Flags_Any (IS_PRIVATE) or else
              Class_File_Field_Access_Flags_Any (IS_PROTECTED) or else
              Class_File_Field_Access_Flags_Any (VOLATILE) or else
              Class_File_Field_Access_Flags_Any (TRANSIENT));

   type Class_File_Field (Environment : Class_File_Environment) is record
      Name_Ref, Descriptor_Ref : Utf_8_Constant_Pool_Entry_Access;
      Attributes               : Attribute_Vectors.Vector;
      case Environment is
         when CLASS =>
            Access_Flags_Class : Class_File_Field_Access_Flags;
         when others =>
            Access_Flags_Others : Class_File_Field_Access_Flags_Any;
      end case;
   end record;

   function Read_Class_File_Field
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class)
   return Class_File_Field;

   procedure Write_Class_File_Field
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Class_File_Field);

   for Class_File_Field'Input use Read_Class_File_Field;
   for Class_File_Field'Write use Write_Class_File_Field;

   package Field_Vectors is new
      Ada.Containers.Indefinite_Vectors (Positive, Class_File_Field);

   procedure Read_Field_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Field_Vectors.Vector);

   procedure Write_Field_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Field_Vectors.Vector);

   ------------------------
   -- Class File Methods --
   ------------------------

   type Class_File_Method_Access is
     (PUBLIC,
      IS_PRIVATE,
      IS_PROTECTED,
      STATIC,
      FINAL,
      IS_SYNCHRONIZED,
      NATIVE,
      IS_ABSTRACT) with Size => 16;

   for Class_File_Method_Access use
     (PUBLIC          => 2 ** 0,
      IS_PRIVATE      => 2 ** 1,
      IS_PROTECTED    => 2 ** 2,
      STATIC          => 2 ** 3,
      FINAL           => 2 ** 4,
      IS_SYNCHRONIZED => 2 ** 5,
      NATIVE          => 2 ** 9,
      IS_ABSTRACT     => 2 ** 11);

   type Class_File_Method_Access_Flags is
      array (Class_File_Method_Access'First .. Class_File_Method_Access'Last)
      of Boolean with Component_Size => 1;

   type Class_File_Method_Access_Flags_Any is
      new Class_File_Method_Access_Flags
      with Predicate =>
         not (Class_File_Method_Access_Flags_Any (IS_PRIVATE) or else
              Class_File_Method_Access_Flags_Any (IS_PROTECTED) or else
              Class_File_Method_Access_Flags_Any (STATIC) or else
              Class_File_Method_Access_Flags_Any (FINAL) or else
              Class_File_Method_Access_Flags_Any (IS_SYNCHRONIZED) or else
              Class_File_Method_Access_Flags_Any (NATIVE));

   type Class_File_Method (Environment : Class_File_Environment) is record
      Name_Ref, Descriptor_Ref : Utf_8_Constant_Pool_Entry_Access;
      Attributes               : Attribute_Vectors.Vector;
      case Environment is
         when CLASS | INSTANCE =>
            Access_Flags_Class : Class_File_Method_Access_Flags;
         when others =>
            Access_Flags_Others : Class_File_Method_Access_Flags_Any;
      end case;
   end record;

   function Read_Class_File_Method
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class)
   return Class_File_Method;

   procedure Write_Class_File_Method
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Class_File_Method);

   for Class_File_Method'Input use Read_Class_File_Method;
   for Class_File_Method'Write use Write_Class_File_Method;

   package Method_Vectors is new
      Ada.Containers.Indefinite_Vectors (Positive, Class_File_Method);

   procedure Read_Method_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Method_Vectors.Vector);

   procedure Write_Method_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Method_Vectors.Vector);

   ----------------
   -- Class File --
   ----------------

   type Class_File is record
      Magic         : u4.Big_Endian range 16#CAFEBABE# .. 16#CAFEBABE#;
      Minor_Version : u2.Big_Endian;
      Major_Version : u2.Big_Endian;
      --  Constant_Pool : Constant_Pool_Vectors.Vector;
      --  Access_Flags  : Class_File_Access_Flags;
      --  This_Class    : Class_Constant_Pool_Entry_Access;
      --  Super_Class   : Class_Constant_Pool_Entry_Access_Optional;
      --  Interfaces    : Interface_Vectors.Vector;
      --  Fields        : Field_Vectors.Vector;
      --  Methods       : Method_Vectors.Vector;
      --  Attributes    : Attribute_Vectors.Vector;
   end record;

   procedure Read_Class_File
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Class_File);

   procedure Write_Class_File
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Class_File);
   
   for Class_File'Read use Read_Class_File;
   for Class_File'Write use Write_Class_File;

end File_Formats.Java.Class;