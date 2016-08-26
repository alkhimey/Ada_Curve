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
	 
         when DE_CASTELIJAU | LAGRANGE_EQUIDISTANT | LAGRANGE_CHEBYSHEV =>
            Knots_To_Draw := 1; -- No knots
	    
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
                  null; -- not implemented yet
		  
               when CATMULL_ROM  => 
                  P := CRV.Eval_Catmull_Rom( Control_Points, Knot, T);
		  
               when LAGRANGE_EQUIDISTANT =>
                  P := CRV.Eval_Lagrange( Control_Points, CRV.Make_Equidistant_Nodes(Control_Points'Length), T);
		  
               when LAGRANGE_CHEBYSHEV =>
                  P := CRV.Eval_Lagrange( Control_Points, CRV.Make_Chebyshev_Nodes(Control_Points'Length), T);
		     
            end case;

            GL.Immediate.Add_Vertex(Token, Vector2'(P(CRV.X), P(CRV.Y)));
            T := T + 0.015625; -- Power of 2 required for floating point to reach 1.0 exaclty 

         end loop;	 
	 
      end loop;
   end;
   
   GL.Toggles.Disable(GL.Toggles.Line_Smooth);
   
end Draw_Curve;
