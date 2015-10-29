# Ada Curve

This is an experimental package for drawing Bezier curves.


![Screenshot](screen.png)

The degree of the curve is dtermined statically at package instansiation:

```ada
package CRV is new Bezier(Base_Real_Type     => GL.Types.Double, 
                          Control_Points_Num => 5);
```

## Prerequirments

One needs to install cmake to build glfw3 and gprbuild to build OpenGLAda

## Build

```bash
gprbuild  -p -P adacurve.gpr -XWindowing_System=x11 -XGLFW_Version=3
```

