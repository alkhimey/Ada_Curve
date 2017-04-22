--  The MIT License (MIT)
--
--  Copyright (c) 2016-2017 artium@nihamkin.com
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
procedure Draw_Curve(Control_Points : in CRV.Control_Points_Array;
                     Algorithm      : in Algorithm_Type;
                     Knot_Values    : in CRV.Knot_Values_Array) is

   procedure Draw_Curve_Segment(Segment : in Positive := 1) is
      
      STEP : constant := 0.015625; -- Power of 2 required for floating point to reach 1.0 exaclty!
         
      Token : Gl.Immediate.Input_Token := GL.Immediate.Start (Line_Strip);

      T : Gl.Types.Double := 0.0;
      P : CRV.Point_Type := CRV.ORIGIN_POINT;
      Skip_Vertex : Boolean := False;
   begin
   
      T  := 0.0;
         
      while T <= 1.0  loop
         
         Skip_Vertex := False;
          
         case Algorithm is 

            when DE_CASTELIJAU => 
               P := CRV.Eval_De_Castelijau( Control_Points, T);            
                  
            when DE_BOOR       => 
               P := CRV.Eval_De_Boor
                  ( Control_Points        => Control_Points, 
                    Knot_Values           => Knot_Values, 
                    T                     => T,
                    Is_Outside_The_Domain => Skip_Vertex);
               
            when CATMULL_ROM  => 
               P := CRV.Eval_Catmull_Rom( Control_Points, Segment, T);
                  
            when LAGRANGE_EQUIDISTANT =>
               P := CRV.Eval_Lagrange( Control_Points, CRV.Make_Equidistant_Nodes(Control_Points'Length), T);
                  
            when LAGRANGE_CHEBYSHEV =>
               P := CRV.Eval_Lagrange( Control_Points, CRV.Make_Chebyshev_Nodes(Control_Points'Length), T);
                     
         end case;
         
         if not Skip_Vertex then
             GL.Immediate.Add_Vertex(Token, Vector2'(P(CRV.X), P(CRV.Y)));
         end if;
         
         T := T + STEP;

      end loop;        
   
   end Draw_Curve_Segment;
   
begin
   
   
   GL.Toggles.Enable(GL.Toggles.Line_Smooth);
   Gl.Immediate.Set_Color (GL.Types.Colors.Color'(1.0, 1.0, 0.0, 0.0));
   
   case Algorithm is
      when DE_CASTELIJAU | LAGRANGE_EQUIDISTANT | LAGRANGE_CHEBYSHEV | DE_BOOR =>
         Draw_Curve_Segment;
           
      when CATMULL_ROM => 
         for Segment in Positive range 1 .. Control_Points'Length - 3 loop
            Draw_Curve_Segment(Segment); 
         end loop;
   
   end case;

   GL.Toggles.Disable(GL.Toggles.Line_Smooth);
   
end Draw_Curve;
