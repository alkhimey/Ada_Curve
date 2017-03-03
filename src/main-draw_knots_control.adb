--  The MIT License (MIT)
--
--  Copyright (c) 2017 artium@nihamkin.com
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

with GL.Types;

separate (Main)
procedure Draw_Knots_Control(Knot_Values    : in CRV.Knot_Values_Array;
                             Hovered_Knot   : Natural := 0;
                             Selected_Knot  : Natural := 0) is
   

   
begin
   -- Draw the ruler
   --
   declare
      Token : Gl.Immediate.Input_Token := GL.Immediate.Start (Line_Strip);
   begin
      Gl.Immediate.Set_Color (GL.Types.Colors.Color'(0.3, 0.3, 0.3, 0.0));
      
      GL.Immediate.Add_Vertex(Token, Vector2'(Calculate_Knot_H_Pos(0.0), KNOTS_RULER_V_POS));
      GL.Immediate.Add_Vertex(Token, Vector2'(Calculate_Knot_H_Pos(1.0), KNOTS_RULER_V_POS));
   end;
      
   -- Draw the knots
   -- 
   for I in Knot_Values'Range Loop  
      declare
         D            : constant := 4.0;
         KNOT_H_POS   : Gl.Types.Double := Calculate_Knot_H_Pos(Knot_Values(I));
         
         Token : Gl.Immediate.Input_Token := GL.Immediate.Start (Polygon);         
      begin
      
         if I = Selected_Knot then
            Gl.Immediate.Set_Color (GL.Types.Colors.Color'(0.3, 0.3, 0.3, 0.0));
         elsif I = Hovered_Knot then    
            Gl.Immediate.Set_Color (GL.Types.Colors.Color'(0.0, 0.5, 0.0, 0.0));
         else
            Gl.Immediate.Set_Color (GL.Types.Colors.Color'(0.6, 0.6, 0.6, 0.0));
         end if;
         
         GL.Immediate.Add_Vertex(Token, Vector2'
                                   (KNOT_H_POS        + D, 
                                    KNOTS_RULER_V_POS + D));
         
         GL.Immediate.Add_Vertex(Token, Vector2'
                                   (KNOT_H_POS        - D, 
                                    KNOTS_RULER_V_POS + D));
         
         GL.Immediate.Add_Vertex(Token, Vector2'
                                   (KNOT_H_POS        - D, 
                                    KNOTS_RULER_V_POS - D));
         
         GL.Immediate.Add_Vertex(Token, Vector2'
                                   (KNOT_H_POS        + D, 
                                    KNOTS_RULER_V_POS - D));
     
      end;
   end loop;
    
end Draw_Knots_Control;
