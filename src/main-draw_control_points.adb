

separate (Main)
procedure Draw_Control_Points(Control_Points : CRV.Control_Points_Array;
			      Hovered_Point  : Natural := 0;
			      Selected_Point : Natural := 0) is
   
begin
   
   
   -- Draw the control points (as squares)
   --
   for I in Control_Points'Range Loop
      
      declare
	 Token : Gl.Immediate.Input_Token := GL.Immediate.Start (Polygon);
	 
	 D : constant := 4.0;
      begin
	 
	 if I = Selected_Point then
	    Gl.Immediate.Set_Color (GL.Types.Colors.Color'(0.3, 0.3, 0.3, 0.0));
	 else
	    Gl.Immediate.Set_Color (GL.Types.Colors.Color'(0.6, 0.6, 0.6, 0.0));
	 end if;
	 
	 GL.Immediate.Add_Vertex(Token, Vector2'
				   (Control_Points(I)(CRV.X) + D, 
				    Control_Points(I)(CRV.Y) + D));
	 
	 GL.Immediate.Add_Vertex(Token, Vector2'
				   (Control_Points(I)(CRV.X) - D, 
				    Control_Points(I)(CRV.Y) + D));
	 
	 GL.Immediate.Add_Vertex(Token, Vector2'
				   (Control_Points(I)(CRV.X) - D, 
				    Control_Points(I)(CRV.Y) - D));
	 
	 GL.Immediate.Add_Vertex(Token, Vector2'
				   (Control_Points(I)(CRV.X) + D, 
				    Control_Points(I)(CRV.Y) - D));

	 
      end;
   end loop;

   
   
end Draw_Control_Points;
