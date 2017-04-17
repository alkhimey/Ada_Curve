--  The MIT License (MIT)
--
--  Copyright (c) 2016 artium@nihamkin.com
--
--  Permission is hereby granted, free of charge, to any person obtaining a copy
--  of this software and associated documentation files (the "Software"), to deal
--  in the Software without restriction, including without limitation the rights
--  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
--  copies of the Software, and to permit persons to whom the Software is
--  furnished to do so, subject to the following conditions:
--
--  The above copyright notice and this permission notice shall be included in
--  all copies or substantial portions of the Software.
--
--  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
--  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
--  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
--  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
--  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
--  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
--  THE SOFTWARE.
-- 
--

with Curve;
with Ada.Text_IO;
use Ada.Text_IO;

with Ada.Command_Line;

with Ada.Strings.Fixed;

with Glfw.Windows.Context;
with Glfw.Input.Mouse;
with Glfw.Input.Keys;
with Glfw.Monitors;
with Glfw.Windows.Hints;
with Glfw.Errors;
with Glfw;

with GL.Types.Colors;
with GL.Buffers;
with GL.Fixed.Matrix;
with GL.Types;
with GL.Immediate;
with GL.Toggles;
with GL.Raster;


with FTGL.Fonts;

procedure Main is
   
   package GL_Double_IO is new Float_IO(GL.Types.Double); 
   use GL_Double_IO;
   
   package Natural_IO is new Integer_IO(Natural);
   use Natural_IO;
   
   use GL.Types;
   use GL.Types.Doubles;
   use GL.Fixed.Matrix;
   use GL.Buffers;
   use type GL.Types.Double;
  
   package CRV is new Curve(Base_Real_Type     => GL.Types.Double, 
                            Dimension          => 2);
   
   -- Constants
   ------------
   
   D : constant Gl.Types.Double := 4.0; -- Diameter of a drawn point
   WINDOW_WIDTH : constant := 800;
   WINDOW_HEIGHT : constant := 600;
   
   MAX_NUMBER_OF_CONTROL_POINTS : constant Positive := 99;
   MIN_NUMBER_OF_CONTROL_POINTS : constant Positive := 4; -- For Catmull-Rom
   
   
   KNOTS_RULER_V_POS      : constant Gl.Types.Double := GL.Types.Double(WINDOW_HEIGHT) - 50.0;
   KNOTS_RULER_LEFT_COORDINATE  : constant := 100.0;
   KNOTS_RULER_RIGHT_COORDINATE : constant := GL.Types.Double(WINDOW_WIDTH) - 100.0;
   
   -- Types
   --------
   
   type Algorithm_Type is (DE_CASTELIJAU, DE_BOOR, CATMULL_ROM, LAGRANGE_EQUIDISTANT, LAGRANGE_CHEBYSHEV);
   
   
   type Test_Window is new Glfw.Windows.Window with record
      
      Control_Points : CRV.Control_Points_Array(1..MAX_NUMBER_OF_CONTROL_POINTS) := 
        (1 => (CRV.X => 100.0, CRV.Y => 100.0),
         2 => (CRV.X => 50.0,  CRV.Y => 200.0),
         3 => (CRV.X => 100.0, CRV.Y => 300.0),
         4 => (CRV.X => 500.0, CRV.Y => 400.0),
         5 => (CRV.X => 200.0, CRV.Y => 200.0),
         6 => (CRV.X => 30.0,  CRV.Y => 150.0),
         others => (CRV.X => 0.0,   CRV.Y => 0.0));
      
      -- Note to self - this was bad idea to use static array of maximal size and a sepearte value to 
      -- represent it's actual size.
      --
      Num_Of_Control_Points : Positive range 1 .. MAX_NUMBER_OF_CONTROL_POINTS := 6;
      
      Original_X, Original_Y : GL.Types.Double := 0.0;
      Delta_X, Delta_Y : GL.Types.Double := 0.0;
      
      
      Selected_Point, Hovered_Point : Natural := 0;
      
      Algorithm : Algorithm_Type := DE_CASTELIJAU;
      
      Help_Overlay_Required : Boolean := False;
      
      Display_Control_Polygon : Boolean := True;
      
      -- "if we want to define a B-spline curve of degree p with n + 1 control points, we have to supply n + p + 2"
      Knot_Values : CRV.Knot_Values_Array (1 .. 10) := (0.0, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9);
      Num_Of_Knots : Positive range 1 ..  103 := 10; -- TODO?
      
      Selected_Knot, Hovered_Knot : Natural := 0;
      
   end record;
   
   -- Separate Procedures and Functions
   ------------------------------------
   function Calculate_Knot_H_Pos(Knot_Value : in CRV.Parametrization_Type) return GL.Types.Double;
   
   -- Overrides
   --------------------------- 
   
   overriding
   procedure Init (Object : not null access Test_Window;
                   Width, Height : Glfw.Size;
                   Title   : String;
                   Monitor : Glfw.Monitors.Monitor := Glfw.Monitors.No_Monitor;
                   Share   : access Glfw.Windows.Window'Class := null);
   
   overriding
   procedure Mouse_Position_Changed (Object : not null access Test_Window;
                                     X, Y   : Glfw.Input.Mouse.Coordinate);
   overriding
   procedure Mouse_Button_Changed (Object  : not null access Test_Window;
                                   Button  : Glfw.Input.Mouse.Button;
                                   State   : Glfw.Input.Button_State;
                                   Mods    : Glfw.Input.Keys.Modifiers);
   
   overriding
   procedure Key_Changed (Object   : not null access Test_Window;
                          Key      : Glfw.Input.Keys.Key;
                          Scancode : Glfw.Input.Keys.Scancode;
                          Action   : Glfw.Input.Keys.Action;
                          Mods     : Glfw.Input.Keys.Modifiers);
   
   -- Procedures and Functions
   --------------------------- 
   
   procedure Init (Object : not null access Test_Window;
                   Width, Height : Glfw.Size;
                   Title   : String;
                   Monitor : Glfw.Monitors.Monitor := Glfw.Monitors.No_Monitor;
                   Share   : access Glfw.Windows.Window'Class := null) is
      Upcast : Glfw.Windows.Window_Reference
        := Glfw.Windows.Window (Object.all)'Access;
   begin
      Upcast.Init (Width, Height, Title, Monitor, Share);
      Object.Enable_Callback (Glfw.Windows.Callbacks.Mouse_Position);
      Object.Enable_Callback (Glfw.Windows.Callbacks.Mouse_Button);
      Object.Enable_Callback (Glfw.Windows.Callbacks.Key);
   end Init;
   
   procedure Mouse_Position_Changed (Object : not null access Test_Window;
                                     X, Y   : Glfw.Input.Mouse.Coordinate) is
      use GL.Types.Doubles;

      use type Glfw.Input.Button_State;
      
      subtype Knot_Index_Type is Positive range  1 .. Object.Num_Of_Knots;
      
      procedure Swap_Knots(Index_1, Index_2 : Knot_Index_Type) is 
         Temp : CRV.Parametrization_Type;
      begin
         Temp := Object.Knot_Values(Index_1);
         Object.Knot_Values(Index_1) := Object.Knot_Values(Index_2);
         Object.Knot_Values(Index_2) := temp;
      end;
      
   begin
 
      if Object.Mouse_Button_State (0) = Glfw.Input.Pressed then
         if Object.Selected_Point /= 0 then
         
            Object.Delta_X := GL.Types.Double (X) - Object.Original_X;
            Object.Delta_Y := GL.Types.Double (Y) - Object.Original_Y;
         
         elsif Object.Selected_Knot /= 0 then 
         
            if    GL.Types.Double(X) <= Calculate_Knot_H_Pos(0.0) then
               Object.Knot_Values(Object.Selected_Knot) := 0.0;
            elsif GL.Types.Double(X) >= Calculate_Knot_H_Pos(1.0) then
               Object.Knot_Values(Object.Selected_Knot) := 1.0;
            else
               Object.Knot_Values(Object.Selected_Knot) := 
                  (GL.Types.Double(X) - KNOTS_RULER_LEFT_COORDINATE) / (KNOTS_RULER_RIGHT_COORDINATE - KNOTS_RULER_LEFT_COORDINATE);
            end if;
            
            while Object.Selected_Knot > Object.Knot_Values'First and then 
                  Object.Knot_Values(Object.Selected_Knot - 1) > Object.Knot_Values(Object.Selected_Knot) loop
               Swap_Knots(Object.Selected_Knot - 1, Object.Selected_Knot);
               Object.Selected_Knot :=  Object.Selected_Knot - 1;
            end loop;
            
            while Object.Selected_Knot < Object.Num_Of_Knots and then 
                  Object.Knot_Values(Object.Selected_Knot + 1) < Object.Knot_Values(Object.Selected_Knot) loop
               Swap_Knots(Object.Selected_Knot + 1, Object.Selected_Knot);
               Object.Selected_Knot :=  Object.Selected_Knot + 1;
            end loop;
            
         end if;   
      end if;
      
   end Mouse_Position_Changed;
   
   
   procedure Mouse_Button_Changed (Object  : not null access Test_Window;
                                   Button  : Glfw.Input.Mouse.Button;
                                   State   : Glfw.Input.Button_State;
                                   Mods    : Glfw.Input.Keys.Modifiers) is
      use GL.Types.Colors;

      use type Glfw.Input.Mouse.Button;
      use type Glfw.Input.Button_State;
      use type Glfw.Input.Mouse.Coordinate;
      
      Found_Point   : Natural := 0;
      X, Y    : Glfw.Input.Mouse.Coordinate;
   begin
      
      Object.Get_Cursor_Pos (X, Y);            
      
      if Button = Glfw.Input.Mouse.Right_Button  and then Object.Selected_Point = 0 and then State = Glfw.Input.Pressed then
         
         for I in Positive range 1 .. Object.Num_Of_Control_Points Loop
            
            if Object.Control_Points(I)(CRV.X) - D <= GL.Types.Double(X) and then
              GL.Types.Double(X) <= Object.Control_Points(I)(CRV.X) + D and then
              Object.Control_Points(I)(CRV.Y) - D <= GL.Types.Double(Y) and then
              GL.Types.Double(Y) <= Object.Control_Points(I)(CRV.Y) + D     then

               Found_Point := I;
               
            end if;
         end loop;
         
         
         if Found_Point /= 0 then
            
            if Object.Num_Of_Control_Points > MIN_NUMBER_OF_CONTROL_POINTS then
               
               for I in Positive range Found_Point .. Object.Num_Of_Control_Points - 1 loop
                  Object.Control_Points(I) := Object.Control_Points(I + 1);
               end loop;
               Object.Num_Of_Control_Points := Object.Num_Of_Control_Points - 1;   
               
            end if;
            
         else
            
            if Object.Num_Of_Control_Points < MAX_NUMBER_OF_CONTROL_POINTS and then
              X >= 0.0 and then X <= Glfw.Input.Mouse.Coordinate(WINDOW_WIDTH) and then 
              Y >= 0.0 and then Y <= Glfw.Input.Mouse.Coordinate(WINDOW_HEIGHT) then
               
               Object.Num_Of_Control_Points := Object.Num_Of_Control_Points + 1;   
               Object.Control_Points(Object.Num_Of_Control_Points) := (GL.Types.Double(X), GL.Types.Double(Y));
               
            end if;
         end if;
      
      elsif Button = Glfw.Input.Mouse.Left_Button then
         
         if  State = Glfw.Input.Released then
            
            if Object.Selected_Point /= 0 and then 
              X >= 0.0 and then X <= Glfw.Input.Mouse.Coordinate(WINDOW_WIDTH) and then 
              Y >= 0.0 and then Y <= Glfw.Input.Mouse.Coordinate(WINDOW_HEIGHT) then
               
               Object.Control_Points(Object.Selected_Point)(CRV.X) := 
                 Object.Control_Points(Object.Selected_Point)(CRV.X) + Object.Delta_X;
               
               Object.Control_Points(Object.Selected_Point)(CRV.Y) := 
                 Object.Control_Points(Object.Selected_Point)(CRV.Y) + Object.Delta_Y;
               
            end if;
            
            Object.Selected_Point := 0;
            Object.Selected_Knot  := 0;
            
         else
            
            if Object.Hovered_Point /= 0 then
            
               Object.Original_X := GL.Types.Double (X);
               Object.Original_Y := GL.Types.Double (Y);
                         
               Object.Selected_Point := Object.Hovered_Point;
               Object.Delta_X := 0.0;
               Object.Delta_Y := 0.0;
            
            elsif Object.Hovered_Knot /= 0 and then Object.Algorithm = DE_BOOR then 
            
               Object.Selected_Knot := Object.Hovered_Knot;
            
            end if;
         end if;
      end if;
   end Mouse_Button_Changed;
   
   procedure Key_Changed (Object   : not null access Test_Window;
                          Key      : Glfw.Input.Keys.Key;
                          Scancode : Glfw.Input.Keys.Scancode;
                          Action   : Glfw.Input.Keys.Action;
                          Mods     : Glfw.Input.Keys.Modifiers) is
      use type Glfw.Input.Keys.Key;
      use type Glfw.Input.Keys.Action;
   begin
      if Key = Glfw.Input.Keys.Escape then
         Object.Set_Should_Close (True);
      end if;
      
      if Action = Glfw.Input.Keys.Press then
         if    Key = Glfw.Input.Keys.Q or else Key = Glfw.Input.Keys.ESCAPE then
            
            Object.Set_Should_Close (True);
            
         elsif Key = Glfw.Input.Keys.H then
            
            Object.Help_Overlay_Required := True;
            
         elsif Key = Glfw.Input.Keys.A then
         
            Object.Selected_Knot := 0; -- Drop knot

            if Object.Algorithm = Algorithm_Type'Last then 
               Object.Algorithm := Algorithm_Type'First;
            else
               Object.Algorithm := Algorithm_Type'Succ(Object.Algorithm);
            end if;
            
         elsif Key = Glfw.Input.Keys.P then
            
            Object.Display_Control_Polygon := not Object.Display_Control_Polygon;
            
            if Object.Display_Control_Polygon then
               Object.Enable_Callback (Glfw.Windows.Callbacks.Mouse_Position);
               Object.Enable_Callback (Glfw.Windows.Callbacks.Mouse_Button);
            else
               Object.Selected_Point := 0;
               Object.Selected_Knot := 0;
               Object.Disable_Callback (Glfw.Windows.Callbacks.Mouse_Position);
               Object.Disable_Callback (Glfw.Windows.Callbacks.Mouse_Button);
            end if;
         end if;
      end if;
      
      if Action = Glfw.Input.Keys.Release then 
               if Key = Glfw.Input.Keys.H then
            
            Object.Help_Overlay_Required := False;
            
         end if;
      end if;
      
   end Key_Changed; 
   
   -- Constants
   ------------
   BASE_TITLE : constant String := "Ada Curve ";
 
   -- Variables
   ------------
   
   My_Window : aliased Test_Window;
   
   Info_Font : FTGL.Fonts.Polygon_Font;
   
   Font_Loaded : Boolean := False;
     
   -- Separate Procedures and Functions
   ------------------------------------
   function Calculate_Knot_H_Pos(Knot_Value : in CRV.Parametrization_Type) return GL.Types.Double is separate;
   
   procedure Draw_Curve(Control_Points : in CRV.Control_Points_Array;
                        Algorithm      : in Algorithm_Type;
                        Knot_Values    : in CRV.Knot_Values_Array) is separate;

   procedure Draw_Control_Polygon(Control_Points : CRV.Control_Points_Array) is separate;

   procedure Draw_Knots_Control(Knot_Values    : in CRV.Knot_Values_Array;
                                Hovered_Knot   : Natural := 0;
                                Selected_Knot  : Natural := 0) is separate;

   procedure Draw_Control_Points(Control_Points : CRV.Control_Points_Array;
                                 Hovered_Point  : Natural := 0;
                                 Selected_Point : Natural := 0) is separate;
   
   procedure Draw_Help_Overlay is separate;
   
   procedure Determine_Hovered_Object is separate;

begin
   
   Glfw.Init;
   Glfw.Windows.Hints.Set_Resizable(False);
   Glfw.Windows.Hints.Set_Samples(16); -- Anti-aliasing
   My_Window'Access.Init (WINDOW_WIDTH, WINDOW_HEIGHT, Base_Title);
   Glfw.Windows.Context.Make_Current (My_Window'Access);

   Projection.Load_Identity;
   Projection.Apply_Orthogonal (0.0, Double(WINDOW_WIDTH), Double(WINDOW_HEIGHT), 0.0, -1.0, 1.0);

   -- Load and setup font
   --
   if Ada.Command_Line.Argument_Count /= 1 then
      Put_Line ("A path to a font file was not provided as an argument.");
   else
      declare
         Font_Path : constant String := Ada.Command_Line.Argument (1);
      begin
         Info_Font.Load (Font_Path);
         Info_Font.Set_Font_Face_Size (18);
         
         Font_Loaded := True;
      exception
         when FTGL.FTGL_Error =>
            Ada.Text_IO.Put_Line ("Could not load font file " & Font_Path);
      end;
   end if;
   
   
   
   -- Main events loop
   --
   while not My_Window'Access.Should_Close loop
      
      Clear (Buffer_Bits'(others => True));
      
      -- Select the hovered object
      -- This code snippet will not run every frame, however is guaranteed to run when mouse
      -- position changes.
      --
      Determine_Hovered_Object;
      
      --  Output info to screen
      --
      if Font_Loaded then
         
         Modelview.Push;
         
         -- Set origin at bottom left 
         Modelview.Apply_Multiplication((( 1.0,  0.0, 0.0, 0.0),
                                         ( 0.0, -1.0, 0.0, 0.0),
                                         ( 0.0,  0.0, 1.0, 0.0),
                                         ( 0.0,  0.0, 0.0, 1.0) ));
         Modelview.Apply_Translation (0.0, - Double(WINDOW_HEIGHT), 0.0);
         
         Gl.Immediate.Set_Color (GL.Types.Colors.Color'(1.0, 1.0, 1.0, 0.0));
         Modelview.Apply_Translation (15.0, -Double(Info_Font.Descender), 0.0);
         Info_Font.Render (Algorithm_Type'Image(My_Window.Algorithm), (Front => True, others => False));
         
         Modelview.Apply_Translation (250.0, 0.0, 0.0);
         Info_Font.Render (Ada.Strings.Fixed.Trim(Integer'Image(My_Window.Num_Of_Control_Points), Ada.Strings.Left) &
                             " / " &
                             Ada.Strings.Fixed.Trim(Integer'Image(MAX_NUMBER_OF_CONTROL_POINTS), Ada.Strings.Left)  &
                             " Points"
                             , (Front => True, others => False));
         
         
         Modelview.Pop;
      end if;
      
      
      declare
            Control_Points_For_Drawing : CRV.Control_Points_Array := My_Window.Control_Points(1..My_Window.Num_Of_Control_Points);            
      begin
         
         if My_Window.Selected_Point in Control_Points_For_Drawing'Range then
            
            Control_Points_For_Drawing(My_Window.Selected_Point)(CRV.X) := 
              My_Window.Control_Points(My_Window.Selected_Point)(CRV.X) + My_Window.Delta_X;
            
            Control_Points_For_Drawing(My_Window.Selected_Point)(CRV.Y) := 
              My_Window.Control_Points(My_Window.Selected_Point)(CRV.Y) + My_Window.Delta_Y;
            
         end if;
         
         
         if My_Window.Display_Control_Polygon then
         
            -- Draw the visualisation of the knot vector
            --
            if My_Window.Algorithm = DE_BOOR then
               Draw_Knots_Control(Knot_Values   => My_Window.Knot_Values(1..My_Window.Num_Of_Knots),
                                  Selected_Knot => My_Window.Selected_Knot,
                                  Hovered_Knot  => My_Window.Hovered_Knot);
            end if;
            
            
            -- Draw the control polygon and points
            --
            Draw_Control_Polygon(Control_Points => Control_Points_For_Drawing);
            
            Draw_Control_Points(Control_Points => Control_Points_For_Drawing,
                                Selected_Point => My_Window.Selected_Point,
                                Hovered_Point  => My_Window.Hovered_Point);
         end if;
           
         -- Draw the curve. Use common knot values which might be relevant only
         -- to portion of algorithms.
         --    
         Draw_Curve(Control_Points_For_Drawing, My_Window.Algorithm, My_Window.Knot_Values(1..My_Window.Num_Of_Knots));
         
      end;
      
      -- Draw help overlay on top of everything else
      --
      if My_Window.Help_Overlay_Required then 
         
         Draw_Help_Overlay;
         
      end if;
      
      
      -- Window maintanace operations 
      --
      GL.Flush;
      Glfw.Windows.Context.Swap_Buffers (My_Window'Access);    
      Glfw.Input.Wait_For_Events;
     
   end loop;

   Glfw.Shutdown;
 
end Main;
