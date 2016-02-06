
separate (Main)
procedure Draw_Curve(Control_Points : CRV.Control_Points_Array;
		     Algorithm      : Algorithm_Type  ) is
   
   Knots_To_Draw : Positive := 1;
   
begin
   
   
   GL.Toggles.Enable(GL.Toggles.Line_Smooth);
   
   declare
      Token : Gl.Immediate.Input_Token := GL.Immediate.Start (Line_Strip);

      T : Gl.Types.Double := 0.0;
      P : CRV.Point_Type := CRV.ORIGIN_POINT;
      
   begin
      
      case Algorithm is 
	 
	 when DE_CASTELIJAU =>
	    Knots_To_Draw := 1;	    
	    
	 when DE_BOOR       => 	    
	    null;
	    
	 when CATMULL_ROM => 
	    Knots_To_Draw := Control_Points'Length - 3; 
	    	    
      end case;

      
      Gl.Immediate.Set_Color (GL.Types.Colors.Color'(1.0, 1.0, 0.0, 0.0));
      
      for Knot in Positive range 1 .. Knots_To_Draw loop
	 
	 T  := 0.0;
	 
	 while T <= 1.0  loop
	    
	    case Algorithm is 
	       
	       when DE_CASTELIJAU => 
		  P := CRV.Eval_De_Castelijau( Control_Points, T);	    
		  
	       when DE_BOOR       => 
		  null;
		  
	       when CATMULL_ROM  => 
		  P := CRV.Eval_Catmull_Rom( Control_Points, Knot, T);
		  
	    end case;

	    GL.Immediate.Add_Vertex(Token, Vector2'(P(CRV.X), P(CRV.Y)));
	    T := T + 0.015625; -- Power of 2 required for floating point to reach 1.0 exaclty 
	    
	 end loop;	 
	 
      end loop;
   end;
   
   GL.Toggles.Disable(GL.Toggles.Line_Smooth);
   
end Draw_Curve;
