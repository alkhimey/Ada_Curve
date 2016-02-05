

separate (Main)
procedure Draw_Control_Polygon(Control_Points : CRV.Control_Points_Array) is
   
   Token : Gl.Immediate.Input_Token := GL.Immediate.Start (Line_Strip);
   
begin
    
   Gl.Immediate.Set_Color (GL.Types.Colors.Color'(0.3, 0.3, 0.3, 0.0));
   
   for I in Control_Points'Range loop
      GL.Immediate.Add_Vertex(Token, Vector2'
				(Control_Points(I)(CRV.X), 
				 Control_Points(I)(CRV.Y)));
   end loop;	 
   
end Draw_Control_Polygon;
