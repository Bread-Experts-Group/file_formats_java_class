pragma Ada_2022;

with Ada.Unchecked_Conversion;

package body File_Formats.Java.Class is

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

   ---------------------------
   -- Read_Attribute_Vector --
   ---------------------------

   procedure Read_Attribute_Vector
     (Stream : not null access Ada.Streams.Root_Stream_Type'Class;
      Item   : out Attribute_Vectors.Vector'Class;
      Pool   : Constant_Pool_Maps.Map)
   is separate;

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

   -----------------------
   -- Read_Field_Vector --
   -----------------------

   procedure Read_Field_Vector
     (Stream      : not null access Ada.Streams.Root_Stream_Type'Class;
      Item        : out Field_Vectors.Vector;
      Pool        : Constant_Pool_Maps.Map;
      Environment : Class_File_Environment)
   is separate;

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

   ------------------------
   -- Read_Method_Vector --
   ------------------------

   procedure Read_Method_Vector
     (Stream      : not null access Ada.Streams.Root_Stream_Type'Class;
      Item        : out Method_Vectors.Vector;
      Pool        : Constant_Pool_Maps.Map;
      Environment : Class_File_Environment)
   is separate;

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
      Super_Class_Idx : u2.Big_Endian;
      Interfaces      : Interface_Vectors.Vector;
      Fields          : Field_Vectors.Vector;
      Methods         : Method_Vectors.Vector;
      Attributes      : Attribute_Vectors.Vector;

      function u2_To_Class_Access_Flags is new
        Ada.Unchecked_Conversion (u2.Big_Endian, Class_File_Access_Flags);
   begin
      Class_File_Magic'Read (Stream, Magic);
      u2.Big_Endian'Read (Stream, Minor_Version);
      u2.Big_Endian'Read (Stream, Major_Version);
      Read_Constant_Pool_Map (Stream, Constant_Pool);
      Access_Flags := u2_To_Class_Access_Flags (u2.Big_Endian'Input (Stream));
      Constant_Pool_Index'Read (Stream, This_Class_Idx);
      u2.Big_Endian'Read (Stream, Super_Class_Idx);
      declare
         Interfaces_Count : i2.Big_Endian;
      begin
         i2.Big_Endian'Read (Stream, Interfaces_Count);
         for Index in 1 .. Interfaces_Count loop
            Interfaces.Append
              (Class_Constant_Pool_Entry (Constant_Pool.Element (Index)));
         end loop;
      end;
      Read_Field_Vector
        (Stream,
         Fields,
         Constant_Pool,
         (if Access_Flags.IS_INTERFACE then IS_INTERFACE else CLASS));
      Read_Method_Vector
        (Stream,
         Methods,
         Constant_Pool,
         (if Access_Flags.IS_INTERFACE then IS_INTERFACE else CLASS));
      Read_Attribute_Vector (Stream, Attributes, Constant_Pool);

      return
        (Magic,
         Minor_Version,
         Major_Version,
         Constant_Pool,
         Access_Flags,
           new Class_Constant_Pool_Entry'
             (Class_Constant_Pool_Entry
                (Constant_Pool.Element (This_Class_Idx))),
           (if Constant_Pool.Contains (Super_Class_Idx)
            then
              new Class_Constant_Pool_Entry'
                (Class_Constant_Pool_Entry
                   (Constant_Pool.Element (Constant_Pool_Index (Super_Class_Idx))))
            else null),
         Interfaces,
         Fields,
         Methods,
         Attributes);
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
