# Ada Curve


Fun and experimentation with curve drawing algorithms and Ada.

![Screenshot](screen.png)

## Currently Implemented

* Catmull Rom
* De Castelijau

## Prerequirments

One needs to install cmake to build glfw3 and gprbuild to build OpenGLAda. 

## Build

```bash
gprbuild  -p -P adacurve.gpr -XWindowing_System=x11 -XGLFW_Version=3
```

## Run

```bash
./bin/main ./OpenGLAda/tests/ftgl/SourceCodePro-Regular.ttf
```

Path to the font file is optional and is required only for displaying the text on the screen.

