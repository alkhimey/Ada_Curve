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
procedure Draw_Knots_Control(Knot_Values    : in CRV.Knot_Values_Array)is
   
   LEFT_COORDINATE  : constant := 100.0;
   RIGHT_COORDINATE : constant := GL.Types.Double(WINDOW_WIDTH) - 100.0;
   
   RULER_H_POS      : constant := GL.Types.Double(WINDOW_HEIGHT) - 50.0;
   
   --Token : Gl.Immediate.Input_Token := GL.Immediate.Start (Line_Strip);
   
begin
   -- Draw the ruler
   --
   declare
      Token : Gl.Immediate.Input_Token := GL.Immediate.Start (Line_Strip);
   begin
      Gl.Immediate.Set_Color (GL.Types.Colors.Color'(0.3, 0.3, 0.3, 0.0));
      GL.Immediate.Add_Vertex(Token, Vector2'(LEFT_COORDINATE, RULER_H_POS));
      GL.Immediate.Add_Vertex(Token, Vector2'(RIGHT_COORDINATE, RULER_H_POS));
   end;
      
   -- Draw the knots
   -- 
   for I in Knot_Values'Range Loop  
      declare
         D            : constant := 4.0;
         KNOT_V_POS   : GL.Types.Double := LEFT_COORDINATE + GL.Types.Double(Knot_Values(I)) * (RIGHT_COORDINATE - LEFT_COORDINATE);
         
         Token : Gl.Immediate.Input_Token := GL.Immediate.Start (Polygon);         
      begin
         Gl.Immediate.Set_Color (GL.Types.Colors.Color'(0.6, 0.6, 0.6, 0.0));
         
         GL.Immediate.Add_Vertex(Token, Vector2'
                                   (KNOT_V_POS  + D, 
                                    RULER_H_POS + D));
         
         GL.Immediate.Add_Vertex(Token, Vector2'
                                   (KNOT_V_POS  - D, 
                                    RULER_H_POS + D));
         
         GL.Immediate.Add_Vertex(Token, Vector2'
                                   (KNOT_V_POS  - D, 
                                    RULER_H_POS - D));
         
         GL.Immediate.Add_Vertex(Token, Vector2'
                                   (KNOT_V_POS  + D, 
                                    RULER_H_POS - D));
     
      end;
   end loop;
    
end Draw_Knots_Control;
