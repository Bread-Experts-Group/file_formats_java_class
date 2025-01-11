pragma Ada_2022;

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

   ----------------------------
   -- Read_Constant_Pool_Map --
   ----------------------------

   procedure Read_Constant_Pool_Map
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Constant_Pool_Maps.Map)
   is separate;

   -----------------------------
   -- Write_Constant_Pool_Map --
   -----------------------------

   procedure Write_Constant_Pool_Map
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : Constant_Pool_Maps.Map) is
   begin
      pragma
        Compile_Time_Warning
          (Standard.True, "Write_Constant_Pool_Map unimplemented");
      raise Program_Error
        with "Unimplemented procedure Write_Constant_Pool_Map";
   end Write_Constant_Pool_Map;

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
      Magic           : Class_File_Magic;
      Minor_Version   : u2.Big_Endian;
      Major_Version   : u2.Big_Endian;
      Constant_Pool   : Constant_Pool_Maps.Map;
      Access_Flags    : Class_File_Access_Flags;
      This_Class_Idx  : Constant_Pool_Index;
      Super_Class_Idx : Constant_Pool_Index;
      Interfaces      : Interface_Vectors.Vector;
      
      function u2_To_Class_Access_Flags is new Ada.Unchecked_Conversion (u2.Big_Endian, Class_File_Access_Flags);
   begin
      pragma
        Compile_Time_Warning (Standard.True, "Read_Class_File unfinished");
      Class_File_Magic'Read (Stream, Magic);
      u2.Big_Endian'Read (Stream, Minor_Version);
      u2.Big_Endian'Read (Stream, Major_Version);
      Read_Constant_Pool_Map (Stream, Constant_Pool);
      Access_Flags := u2_To_Class_Access_Flags (u2.Big_Endian'Input (Stream));
      Constant_Pool_Index'Read (Stream, This_Class_Idx);
      Constant_Pool_Index'Read (Stream, Super_Class_Idx);

      Ada.Text_IO.Put_Line ("Magic        :" & Magic'Image);
      Ada.Text_IO.Put_Line ("Major V#     :" & Major_Version'Image);
      Ada.Text_IO.Put_Line ("Minor V#     :" & Minor_Version'Image);
      Ada.Text_IO.Put_Line ("Constant Pool:" & Constant_Pool'Image);
      Ada.Text_IO.Put_Line ("Access       :" & Access_Flags'Image);
      Ada.Text_IO.Put_Line ("This  #      :" & This_Class_Idx'Image);
      Ada.Text_IO.Put_Line ("Super #      :" & Super_Class_Idx'Image);
      declare
        Interfaces_Count : i2.Big_Endian;
      begin
        i2.Big_Endian'Read (Stream, Interfaces_Count);
        Ada.Text_IO.Put_Line ("Interfaces # :" & Interfaces_Count'Image);
        for Index in 1 .. Interfaces_Count loop
          Interfaces.Append (new Class_Constant_Pool_Entry'(Class_Constant_Pool_Entry (Constant_Pool.Element (Index))));
        end loop;
      end;
      declare
        Fields_Count : u2.Big_Endian;
      begin
        u2.Big_Endian'Read (Stream, Fields_Count);
        Ada.Text_IO.Put_Line ("Fields     # :" & Fields_Count'Image);
      end;
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
