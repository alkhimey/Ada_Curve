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

separate (Main)
procedure Determine_Hovered_Object is
   X, Y : Glfw.Input.Mouse.Coordinate;
begin
      
   My_Window.Hovered_Point := 0;
   My_Window.Hovered_Knot  := 0;      
         
   Get_Cursor_Pos(My_Window'Access, X, Y);
   if My_Window.Selected_Point = 0 and then My_Window.Selected_Knot = 0 then
   
   for I in Positive range 1 .. My_Window.Num_Of_Control_Points loop
            
      if My_Window.Control_Points(I)(CRV.X) - D <= GL.Types.Double(X) and then
         GL.Types.Double(X) <= My_Window.Control_Points(I)(CRV.X) + D and then
         My_Window.Control_Points(I)(CRV.Y) - D <= GL.Types.Double(Y) and then
         GL.Types.Double(Y) <= My_Window.Control_Points(I)(CRV.Y) + D     then
               
                  My_Window.Hovered_Point := I;
               
      end if;
   end loop;
         
   -- Control points get precedence over knots
   --
        
   if My_Window.Hovered_Point = 0 then
       
      for I in Positive range 1 .. My_Window.Num_Of_Knots loop
            
         if Calculate_Knot_H_Pos(My_Window.Knot_Values(I)) - D <= GL.Types.Double(X) and then
            GL.Types.Double(X) <= Calculate_Knot_H_Pos(My_Window.Knot_Values(I)) + D and then
            KNOTS_RULER_V_POS - D <= GL.Types.Double(Y) and then
            GL.Types.Double(Y) <= KNOTS_RULER_V_POS + D     then
               
               My_Window.Hovered_Knot := I;
               
         end if;   
      end loop;
   end if;

   end if;

end Determine_Hovered_Object;

