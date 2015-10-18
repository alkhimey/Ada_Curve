with Bezier;
with Text_IO;
use Text_IO;


with Glfw.Windows.Context;
with Glfw.Input.Mouse;
with Glfw.Input.Keys;
with Glfw.Monitors;
with Glfw;

with GL.Types.Colors;
with GL.Buffers;
with GL.Fixed.Matrix;
with GL.Types;
with GL.Immediate;

procedure Main is
   
   package GL_Double_IO is new Float_IO(GL.Types.Double); 
   use GL_Double_IO;
   
   
   use GL.Types;
   use GL.Types.Doubles;
   use GL.Fixed.Matrix;
   use GL.Buffers;
   use type GL.Types.Double;

   
   
   package CRV is new Bezier(Base_Real_Type     => GL.Types.Double, 
			     Control_Points_Num => 4);
     
   -- Types
   --------
   type Test_Window is new Glfw.Windows.Window with record
      Start_X, Start_Y : GL.Types.Double;
      Color : GL.Types.Colors.Color;
      Redraw : Boolean := False;
   end record;
   
   

   -- Procedures and Functions
   ---------------------------
   
   overriding
   procedure Init (Object : not null access Test_Window;
                   Width, Height : Glfw.Size;
                   Title   : String;
                   Monitor : Glfw.Monitors.Monitor := Glfw.Monitors.No_Monitor;
                   Share   : access Glfw.Windows.Window'Class := null);


   procedure Init (Object : not null access Test_Window;
                   Width, Height : Glfw.Size;
                   Title   : String;
                   Monitor : Glfw.Monitors.Monitor := Glfw.Monitors.No_Monitor;
                   Share   : access Glfw.Windows.Window'Class := null) is
      Upcast : Glfw.Windows.Window_Reference
        := Glfw.Windows.Window (Object.all)'Access;
   begin
      Upcast.Init (Width, Height, Title, Monitor, Share);
      --Object.Enable_Callback (Glfw.Windows.Callbacks.Mouse_Position);
      --Object.Enable_Callback (Glfw.Windows.Callbacks.Mouse_Button);
   end Init;
   
   
   -- Constants
   ------------
   Base_Title : constant String := "Bezier Curve Test ";
   
   CONTROL_POINTS : constant CRV.Control_Points_Array := 
     (1 => (CRV.X => 100.0, CRV.Y => 100.0),
      2 => (CRV.X => 50.0, CRV.Y => 200.0),
      3 => (CRV.X => 100.0, CRV.Y => 300.0),
      4 => (CRV.X => 500.0, CRV.Y => 400.0));
      
   -- Variables
   ------------
   
   My_Window : aliased Test_Window;
   
   
   
begin
   
   
   Glfw.Init;
--   Enable_Print_Errors;

   My_Window'Access.Init (800, 600, Base_Title);
   Glfw.Windows.Context.Make_Current (My_Window'Access);

   Projection.Load_Identity;
   Projection.Apply_Orthogonal (0.0, 800.0, 600.0, 0.0, -1.0, 1.0);

   while not My_Window'Access.Should_Close loop
      
      Clear (Buffer_Bits'(others => True));
      
      -- Draw control polygon lines
      --
      declare
	 Token : Gl.Immediate.Input_Token := GL.Immediate.Start (Line_Strip);
	 
      begin
	 Gl.Immediate.Set_Color (GL.Types.Colors.Color'(1.0, 0.5, 0.5, 0.0));
	 
	 for I in CONTROL_POINTS'Range loop
	    GL.Immediate.Add_Vertex(Token, Vector2'
				      (CONTROL_POINTS(I)(CRV.X), 
				       CONTROL_POINTS(I)(CRV.Y)));
	 end loop;	 
      end;
	  
	  
      -- Draw the curve
      --
      declare
	 Token : Gl.Immediate.Input_Token := GL.Immediate.Start (Line_Strip);
	 type Sampling_Range_Type is delta 0.1 range 0.0 .. 0.0;
	 T : Gl.Types.Double := 0.0;
	 P : CRV.Point_Type;
	 
      begin
	 Gl.Immediate.Set_Color (GL.Types.Colors.Color'(0.0, 1.0, 0.0, 0.0));
	 
	 loop
	    exit when T > 1.0;
	    
	    P := CRV.Bezier( Control_Points, T);
	    
--	    Put(P(CRV.X));
--	    Put(P(CRV.Y));
--	    New_Line;
	    
	    GL.Immediate.Add_Vertex(Token, Vector2'(P(CRV.X), P(CRV.Y)));
	    T := T + 0.05;   
	 end loop;	 
      end;
      
      

      -- Draw the control points 
      
      

      
      GL.Flush;

      Glfw.Windows.Context.Swap_Buffers (My_Window'Access);
      
      Glfw.Input.Wait_For_Events;
      
--      Glfw.Input.Poll_Events;

      
   end loop;

   Glfw.Shutdown;

   
 
   
--   R := B1.Bezier(Control_Points => A,
--		  T              => 0.5);
   

      
end Main;
