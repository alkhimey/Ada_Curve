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

with GL.Blending;

separate (Main)
procedure Draw_Help_Overlay is
   

   
begin
   
   if Font_Loaded then
      
      GL.Toggles.Enable(GL.Toggles.Blend);
      GL.Blending.Set_Blend_Func(GL.Blending.Src_Alpha, GL.Blending.One_Minus_Src_Alpha);
      
      declare
	 Token : Gl.Immediate.Input_Token := GL.Immediate.Start (Quads);
      begin   
	 Gl.Immediate.Set_Color (GL.Types.Colors.Color'(0.1, 0.1, 0.1, 0.9));
	 
	 GL.Immediate.Add_Vertex(Token, Vector2'(0.0,                  0.0                  ));
	 GL.Immediate.Add_Vertex(Token, Vector2'(0.0,                  Double(WINDOW_HEIGHT)));
	 GL.Immediate.Add_Vertex(Token, Vector2'(Double(WINDOW_WIDTH), Double(WINDOW_HEIGHT)));
	 GL.Immediate.Add_Vertex(Token, Vector2'(Double(WINDOW_WIDTH), 0.0                  ));
      end;
      
      GL.Toggles.Disable(GL.Toggles.Blend);
      
      Gl.Immediate.Set_Color (GL.Types.Colors.Color'(0.1, 0.9, 0.1, 0.0));
      
      Modelview.Push;
      
      -- Set origin at bottom left 
      Modelview.Apply_Multiplication((( 1.0,  0.0, 0.0, 0.0),
				      ( 0.0, -1.0, 0.0, 0.0),
				      ( 0.0,  0.0, 1.0, 0.0),
				      ( 0.0,  0.0, 0.0, 1.0) ));
      
      Modelview.Apply_Translation (15.0, -Double(Info_Font.Line_Height), 0.0);
      
      Info_Font.Render ("Use right mouse to add or delete points and left to move them", (Front => True, others => False));
      
      Modelview.Apply_Translation ( 0.0, - 2.0 * Double(Info_Font.Line_Height), 0.0);  
      
      Info_Font.Render ("A - Cycle algorithms", (Front => True, others => False));
      
      Modelview.Apply_Translation ( 0.0, -Double(Info_Font.Line_Height), 0.0);  
      
      Info_Font.Render ("P - Toggle control polygon", (Front => True, others => False));
      
      Modelview.Apply_Translation ( 0.0, -Double(Info_Font.Line_Height), 0.0);  
      
      Info_Font.Render ("Q - Quit", (Front => True, others => False));
      
      Modelview.Pop;
      
   end if;
   
end Draw_Help_Overlay;

