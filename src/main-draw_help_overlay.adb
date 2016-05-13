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

      Info_Font.Render ("A - Cycle algorithms", (Front => True, others => False));
      
      Modelview.Apply_Translation ( 0.0, -Double(Info_Font.Line_Height), 0.0);  
      
      Info_Font.Render ("P - Toggle control polygon", (Front => True, others => False));
      
      Modelview.Apply_Translation ( 0.0, -Double(Info_Font.Line_Height), 0.0);  
      
      Info_Font.Render ("Q - Quit", (Front => True, others => False));
      
      Modelview.Pop;
      
   end if;
   
end Draw_Help_Overlay;

