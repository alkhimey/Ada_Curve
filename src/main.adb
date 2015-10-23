with Bezier;
with Text_IO;
use Text_IO;


with Glfw.Windows.Context;
with Glfw.Input.Mouse;
with Glfw.Input.Keys;
with Glfw.Monitors;
with Glfw.Windows.Hints;
with Glfw;

with GL.Types.Colors;
with GL.Buffers;
with GL.Fixed.Matrix;
with GL.Types;
with GL.Immediate;
--with GL.API;
with GL.Toggles;

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

   
   
   package CRV is new Bezier(Base_Real_Type     => GL.Types.Double, 
			     Control_Points_Num => 5);
   
   -- Constants
   ------------
   
   D : constant := 4.0;
   WINDOW_WIDTH : constant := 800;
   WINDOW_HEIGHT : constant := 600;
   
   
   -- Types
   --------
   type Test_Window is new Glfw.Windows.Window with record
      
      Control_Points : CRV.Control_Points_Array := 
	(1 => (CRV.X => 100.0, CRV.Y => 100.0),
	 2 => (CRV.X => 50.0, CRV.Y => 200.0),
	 3 => (CRV.X => 100.0, CRV.Y => 300.0),
	 4 => (CRV.X => 500.0, CRV.Y => 400.0),
	 5 => (CRV.X => 200.0, CRV.Y => 200.0));
      
      
      Original_X, Original_Y : GL.Types.Double := 0.0;
      Delta_X, Delta_Y : GL.Types.Double := 0.0;
      
      
      Selected_Point : Natural := 0;
   end record;
   
   

   -- Procedures and Functions
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
   end Init;
   
   procedure Mouse_Position_Changed (Object : not null access Test_Window;
                                     X, Y   : Glfw.Input.Mouse.Coordinate) is
      use GL.Types.Doubles;

      use type Glfw.Input.Button_State;
   begin
 
      if Object.Mouse_Button_State (0) = Glfw.Input.Pressed  and then Object.Selected_Point /= 0 then
	 
	 Object.Delta_X := GL.Types.Double (X) - Object.Original_X;
	 Object.Delta_Y := GL.Types.Double (Y) - Object.Original_Y;
	 
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
      
      X, Y    : Glfw.Input.Mouse.Coordinate;
   begin
      if Button = 0 then
	 
	 if  State /= Glfw.Input.Pressed then
	    
	    Object.Get_Cursor_Pos (X, Y);
	    
	    if Object.Selected_Point /= 0 and then 
	      X >= 0.0 and then X <= Glfw.Input.Mouse.Coordinate(WINDOW_WIDTH) and then 
	      Y >= 0.0 and then Y <= Glfw.Input.Mouse.Coordinate(WINDOW_HEIGHT) then
	       
	       Object.Control_Points(Object.Selected_Point)(CRV.X) := 
		 Object.Control_Points(Object.Selected_Point)(CRV.X) + Object.Delta_X;
	       
	       Object.Control_Points(Object.Selected_Point)(CRV.Y) := 
		 Object.Control_Points(Object.Selected_Point)(CRV.Y) + Object.Delta_Y;
	       
	    end if;
	    
	    Object.Selected_Point := 0;
	    
	 else 
	    
	    Object.Selected_Point := 0;
	    
	    for I in Object.Control_Points'Range Loop
	       
	       Object.Get_Cursor_Pos (X, Y);
	       Object.Original_X := GL.Types.Double (X);
	       Object.Original_Y := GL.Types.Double (Y);
	       
	       
	       if Object.Control_Points(I)(CRV.X) - 4.0 <= Object.Original_X and then
		 Object.Original_X <= Object.Control_Points(I)(CRV.X) + 4.0 and then
		 Object.Control_Points(I)(CRV.Y) - 4.0 <= Object.Original_Y and then
		 Object.Original_Y<= Object.Control_Points(I)(CRV.Y) + 4.0  then
		 
		  -- Last point precendency
		  Object.Selected_Point := I;
		  Object.Delta_X := 0.0;
		  Object.Delta_Y := 0.0;
	    
		  --Natural_IO.Put(I);
		  --New_Line;
		  
	       end if;
	    end loop;
	 end if;
      end if;
   end Mouse_Button_Changed;
   
   -- Constants
   ------------
   BASE_TITLE : constant String := "Bezier Curve Test ";
   
 
   -- Variables
   ------------
   
   My_Window : aliased Test_Window;
   
   Draw_Control_Points : CRV.Control_Points_Array := My_Window.Control_Points;
   
begin
   
   
   
   Glfw.Init;
--   Enable_Print_Errors;
   
   Glfw.Windows.Hints.Set_Resizable(False);
   My_Window'Access.Init (WINDOW_WIDTH, WINDOW_HEIGHT, Base_Title);
   Glfw.Windows.Context.Make_Current (My_Window'Access);

   Projection.Load_Identity;
   Projection.Apply_Orthogonal (0.0, 800.0, 600.0, 0.0, -1.0, 1.0);

   while not My_Window'Access.Should_Close loop
      
      Clear (Buffer_Bits'(others => True));
      
      
      if My_Window.Selected_Point = 0 then
	 
	 Draw_Control_Points := My_Window.Control_Points;
	 
      else
	 
	 Draw_Control_Points(My_Window.Selected_Point)(CRV.X) := 
	   My_Window.Control_Points(My_Window.Selected_Point)(CRV.X) + My_Window.Delta_X;
	 
	 Draw_Control_Points(My_Window.Selected_Point)(CRV.Y) := 
	   My_Window.Control_Points(My_Window.Selected_Point)(CRV.Y) + My_Window.Delta_Y;
	
      end if;
      
      -- Draw control polygon lines
      --
      declare
	 Token : Gl.Immediate.Input_Token := GL.Immediate.Start (Line_Strip);
	 
      begin
	 Gl.Immediate.Set_Color (GL.Types.Colors.Color'(0.3, 0.3, 0.3, 0.0));
	 
	 for I in Draw_Control_Points'Range loop
	    GL.Immediate.Add_Vertex(Token, Vector2'
				      (Draw_Control_Points(I)(CRV.X), 
				       Draw_Control_Points(I)(CRV.Y)));
	 end loop;	 
      end;
      
      -- Draw the control points (as squares)
      --
      for I in Draw_Control_Points'Range Loop
	 
	 declare
	    Token : Gl.Immediate.Input_Token := GL.Immediate.Start (Polygon);
	    
	    D : constant := 4.0;
	 begin
	    
	    if I = My_Window.Selected_Point then
	       Gl.Immediate.Set_Color (GL.Types.Colors.Color'(0.3, 0.3, 0.3, 0.0));
	    else
	       Gl.Immediate.Set_Color (GL.Types.Colors.Color'(0.6, 0.6, 0.6, 0.0));
	    end if;
	       
	    GL.Immediate.Add_Vertex(Token, Vector2'
				      (Draw_Control_Points(I)(CRV.X) + D, 
				       Draw_Control_Points(I)(CRV.Y) + D));
	    
	    GL.Immediate.Add_Vertex(Token, Vector2'
				      (Draw_Control_Points(I)(CRV.X) - D, 
				       Draw_Control_Points(I)(CRV.Y) + D));
	    
	    GL.Immediate.Add_Vertex(Token, Vector2'
				      (Draw_Control_Points(I)(CRV.X) - D, 
				       Draw_Control_Points(I)(CRV.Y) - D));
	    
	    GL.Immediate.Add_Vertex(Token, Vector2'
				      (Draw_Control_Points(I)(CRV.X) + D, 
				       Draw_Control_Points(I)(CRV.Y) - D));

	    
	 end;
      end loop;
      
	  
      -- Draw the curve
      --
      
      GL.Toggles.Enable(GL.Toggles.Line_Smooth);
      
      declare
	 Token : Gl.Immediate.Input_Token := GL.Immediate.Start (Line_Strip);
	 type Sampling_Range_Type is delta 0.1 range 0.0 .. 0.0;
	 T : Gl.Types.Double := 0.0;
	 P : CRV.Point_Type;
	 
      begin
	 Gl.Immediate.Set_Color (GL.Types.Colors.Color'(1.0, 1.0, 0.0, 0.0));
	 
	 loop
	    exit when T > 1.0;
	    
	    P := CRV.Bezier( Draw_Control_Points, T);
	    
	    GL.Immediate.Add_Vertex(Token, Vector2'(P(CRV.X), P(CRV.Y)));
	    T := T + 0.015625; -- Power of 2 required for floating point to reach 1.0 exaclty   
	 end loop;	 
	 
      end;
      
      GL.Toggles.Disable(GL.Toggles.Line_Smooth);
      
      GL.Flush;

      Glfw.Windows.Context.Swap_Buffers (My_Window'Access);
      
      Glfw.Input.Wait_For_Events;
      
   end loop;

   Glfw.Shutdown;

   
 
   
--   R := B1.Bezier(My_Window.Control_Points => A,
--		  T              => 0.5);
   

      
end Main;
