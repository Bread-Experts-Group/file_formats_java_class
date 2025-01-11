pragma Ada_2022;
pragma Extensions_Allowed (On);

with Ada.Unchecked_Conversion;

--  testing
with Ada.Text_IO;
--  testing end

package body File_Formats.Java.Class is

   ------------------------------
   -- Read_Constant_Pool_Entry --
   ------------------------------

   function Read_Constant_Pool_Entry
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class)
      return Constant_Pool_Entry is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Read_Constant_Pool_Entry unimplemented");
      return
        raise Program_Error
          with "Unimplemented function Read_Constant_Pool_Entry";
   end Read_Constant_Pool_Entry;

   -------------------------------
   -- Write_Constant_Pool_Entry --
   -------------------------------

   procedure Write_Constant_Pool_Entry
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Constant_Pool_Entry) is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Write_Constant_Pool_Entry unimplemented");
      raise Program_Error
        with "Unimplemented procedure Write_Constant_Pool_Entry";
   end Write_Constant_Pool_Entry;

   -------------------------------
   -- Read_Constant_Pool_Vector --
   -------------------------------

   procedure Read_Constant_Pool_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Constant_Pool_Vectors.Vector)
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

      function u4_To_Float is new
        Ada.Unchecked_Conversion (u4.Big_Endian, Standard.Float);
      function u8_To_Double is new
        Ada.Unchecked_Conversion (u8.Big_Endian, Standard.Long_Float);

      use type i2.Big_Endian;
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Read_Constant_Pool_Vector unfinished");
      i2.Big_Endian'Read (Stream, Constant_Pool_Count);
      Item.Set_Length (Ada.Containers.Count_Type (Constant_Pool_Count));
      Constant_Pool_Position := 1;
      loop
         Constant_Pool_Entry_Tag'Read (Stream, Read_Tag);
         case Read_Tag is
            when UTF_8 =>
               declare
                  Length : constant u2.Big_Endian :=
                    u2.Big_Endian'Input (Stream);
                  Bytes  : Standard.String (1 .. Standard.Integer (Length));
               begin
                  Standard.String'Read (Stream, Bytes);
                  Item.Replace_Element
                    (Constant_Pool_Position,
                     Constant_Pool_Entry'(UTF_8, new Standard.String'(Bytes)));
               end;

            when INTEGER =>
               Item.Replace_Element
                 (Constant_Pool_Position,
                  Constant_Pool_Entry'
                    (INTEGER,
                     Standard.Integer (i4.Big_Endian'Input (Stream))));

            when FLOAT =>
               Item.Replace_Element
                 (Constant_Pool_Position,
                  Constant_Pool_Entry'
                    (FLOAT, u4_To_Float (u4.Big_Endian'Input (Stream))));

            when LONG =>
               Item.Replace_Element
                 (Constant_Pool_Position,
                  Constant_Pool_Entry'
                    (LONG,
                     Standard.Long_Integer (i8.Big_Endian'Input (Stream))));

            when DOUBLE =>
               Item.Replace_Element
                 (Constant_Pool_Position,
                  Constant_Pool_Entry'
                    (DOUBLE, u8_To_Double (u8.Big_Endian'Input (Stream))));

            when CLASS | STRING =>
               declare
                  Index : Constant_Pool_Vectors.Cursor :=
                    Item.To_Cursor (Constant_Pool_Index'Input (Stream));
               begin
                  if Index.Has_Element then
                    Ada.Text_IO.Put_Line ("Present" & Index.To_Index'Image);
                  else
                    Ada.Text_IO.Put_Line ("Not Present" & Index.To_Index'Image);
                  end if;
               end;

            when others =>
               raise Program_Error with "Unimplemented tag " & Read_Tag'Image;
         end case;

         Constant_Pool_Position := @ + 1;
         exit when Constant_Pool_Position = Constant_Pool_Count;
      end loop;
      raise Program_Error
        with "Unimplemented procedure Read_Constant_Pool_Vector";
   end Read_Constant_Pool_Vector;

   --------------------------------
   -- Write_Constant_Pool_Vector --
   --------------------------------

   procedure Write_Constant_Pool_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Constant_Pool_Vectors.Vector) is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Write_Constant_Pool_Vector unimplemented");
      raise Program_Error
        with "Unimplemented procedure Write_Constant_Pool_Vector";
   end Write_Constant_Pool_Vector;

   -------------------------------
   -- Read_Class_File_Attribute --
   -------------------------------

   function Read_Class_File_Attribute
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class)
      return Class_File_Attribute is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Read_Class_File_Attribute unimplemented");
      return
        raise Program_Error
          with "Unimplemented function Read_Class_File_Attribute";
   end Read_Class_File_Attribute;

   --------------------------------
   -- Write_Class_File_Attribute --
   --------------------------------

   procedure Write_Class_File_Attribute
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Class_File_Attribute) is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Write_Class_File_Attribute unimplemented");
      raise Program_Error
        with "Unimplemented procedure Write_Class_File_Attribute";
   end Write_Class_File_Attribute;

   ---------------------------
   -- Read_Attribute_Vector --
   ---------------------------

   procedure Read_Attribute_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Attribute_Vectors.Vector) is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Read_Attribute_Vector unimplemented");
      raise Program_Error with "Unimplemented procedure Read_Attribute_Vector";
   end Read_Attribute_Vector;

   ----------------------------
   -- Write_Attribute_Vector --
   ----------------------------

   procedure Write_Attribute_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Attribute_Vectors.Vector) is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Write_Attribute_Vector unimplemented");
      raise Program_Error
        with "Unimplemented procedure Write_Attribute_Vector";
   end Write_Attribute_Vector;

   ---------------------------
   -- Read_Class_File_Field --
   ---------------------------

   function Read_Class_File_Field
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class)
      return Class_File_Field is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Read_Class_File_Field unimplemented");
      return
        raise Program_Error
          with "Unimplemented function Read_Class_File_Field";
   end Read_Class_File_Field;

   ----------------------------
   -- Write_Class_File_Field --
   ----------------------------

   procedure Write_Class_File_Field
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Class_File_Field) is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Write_Class_File_Field unimplemented");
      raise Program_Error
        with "Unimplemented procedure Write_Class_File_Field";
   end Write_Class_File_Field;

   -----------------------
   -- Read_Field_Vector --
   -----------------------

   procedure Read_Field_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Field_Vectors.Vector) is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Read_Field_Vector unimplemented");
      raise Program_Error with "Unimplemented procedure Read_Field_Vector";
   end Read_Field_Vector;

   ------------------------
   -- Write_Field_Vector --
   ------------------------

   procedure Write_Field_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Field_Vectors.Vector) is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Write_Field_Vector unimplemented");
      raise Program_Error with "Unimplemented procedure Write_Field_Vector";
   end Write_Field_Vector;

   ----------------------------
   -- Read_Class_File_Method --
   ----------------------------

   function Read_Class_File_Method
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class)
      return Class_File_Method is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Read_Class_File_Method unimplemented");
      return
        raise Program_Error
          with "Unimplemented function Read_Class_File_Method";
   end Read_Class_File_Method;

   -----------------------------
   -- Write_Class_File_Method --
   -----------------------------

   procedure Write_Class_File_Method
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Class_File_Method) is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Write_Class_File_Method unimplemented");
      raise Program_Error
        with "Unimplemented procedure Write_Class_File_Method";
   end Write_Class_File_Method;

   ------------------------
   -- Read_Method_Vector --
   ------------------------

   procedure Read_Method_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Method_Vectors.Vector) is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Read_Method_Vector unimplemented");
      raise Program_Error with "Unimplemented procedure Read_Method_Vector";
   end Read_Method_Vector;

   -------------------------
   -- Write_Method_Vector --
   -------------------------

   procedure Write_Method_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Method_Vectors.Vector) is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Write_Method_Vector unimplemented");
      raise Program_Error with "Unimplemented procedure Write_Method_Vector";
   end Write_Method_Vector;

   ---------------------
   -- Read_Class_File --
   ---------------------

   function Read_Class_File
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class)
      return Class_File
   is
      Magic         : Class_File_Magic;
      Minor_Version : u2.Big_Endian;
      Major_Version : u2.Big_Endian;
      Constant_Pool : Constant_Pool_Vectors.Vector;
   begin
      pragma
        Compile_Time_Warning (Standard.True, "Read_Class_File unfinished");
      Class_File_Magic'Read (Stream, Magic);
      u2.Big_Endian'Read (Stream, Minor_Version);
      u2.Big_Endian'Read (Stream, Major_Version);
      Read_Constant_Pool_Vector (Stream, Constant_Pool);

      Ada.Text_IO.Put_Line (Magic'Image);
      Ada.Text_IO.Put_Line (Major_Version'Image);
      Ada.Text_IO.Put_Line (Minor_Version'Image);
      Ada.Text_IO.Put_Line (Constant_Pool'Image);
      return
        raise Program_Error with "Unimplemented procedure Read_Class_File";
   end Read_Class_File;

   ----------------------
   -- Write_Class_File --
   ----------------------

   procedure Write_Class_File
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Class_File) is
   begin
      pragma
        Compile_Time_Warning (Standard.True, "Write_Class_File unimplemented");
      raise Program_Error with "Unimplemented procedure Write_Class_File";
   end Write_Class_File;

end File_Formats.Java.Class;
