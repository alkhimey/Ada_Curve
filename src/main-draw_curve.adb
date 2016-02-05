
separate (Main)
procedure Draw_Curve(Control_Points : CRV.Control_Points_Array;
		     Algorithm      : Algorithm_Type  ) is
	
begin
   
   
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
	 
	 P := CRV.Eval_De_Castelijau( Control_Points, T);	    
	 
	 GL.Immediate.Add_Vertex(Token, Vector2'(P(CRV.X), P(CRV.Y)));
	 T := T + 0.015625; -- Power of 2 required for floating point to reach 1.0 exaclty   
      end loop;	 
      
   end;
   
   GL.Toggles.Disable(GL.Toggles.Line_Smooth);
   
end Draw_Curve;
