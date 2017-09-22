all:
	gprbuild  -p -P adacurve.gpr -XWindowing_System=x11 -XGLFW_Version=3
        
clean:
	gprclean -P adacurve.gpr -XWindowing_System=x11 -XGLFW_Version=3
        
run:
	./bin/main ./OpenGLAda/tests/ftgl/SourceCodePro-Regular.ttf

