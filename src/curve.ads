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

with Ada.Numerics.Generic_Elementary_Functions;

generic
   type Base_Real_Type is digits <>; -- Floating point only (can be manually changed to fixed point)
   Dimension          : Positive;
package Curve is
   
   package Base_Type_Math is new Ada.Numerics.Generic_Elementary_Functions(Base_Real_Type);
   
   -- Type Definitions
   -------------------
   
   type Dimension_Type is new Positive range 1 .. Dimension;

   type Point_Type is array( Dimension_Type ) of Base_Real_Type;
   
   subtype Parametrization_Type is Base_Real_Type range 0.0 .. 1.0;
   
   type Control_Points_Array is array(Positive range <>) of Point_Type;
   
   type Interpolation_Nodes_Array is array(Positive range <>) of Parametrization_Type;
   
   type Knot_Values_Array is array(Positive range <>) of Parametrization_Type;
   
   -- Constants
   ------------
   
   ORIGIN_POINT : constant Point_Type := (others => Base_Real_Type(0.0));
   
   X : constant := 1;
   Y : constant := 2;
   Z : constant := 3;
   W : constant := 4;
   
   
   -- Operator definitions
   -----------------------
   
   function "+" (Left, Right : Point_Type) return Point_Type;
   function "-" (Left, Right : Point_Type) return Point_Type;
   function "-" (Right : Point_Type) return Point_Type;
   function "*" (Left  : Point_Type; 
                 Right : Base_Real_Type ) return Point_Type;
   
   function "*" (Left  : Base_Real_Type; 
                 Right : Point_Type ) return Point_Type;
   
   
   
   
   -- Curve functions and procedures
   ---------------------------------
   
   
   function Eval_De_Castelijau( Control_Points : in Control_Points_Array;
                                T              : in Parametrization_Type) return Point_Type;
   
   
   function Eval_De_Boor      ( Control_Points        : in Control_Points_Array;
                                Knot_Values           : in Knot_Values_Array;
                                T                     : in Parametrization_Type;
                                Is_Outside_The_Domain : out Boolean) return Point_Type with
      Pre => Control_Points'First = Knot_Values'First and then   -- Implementation depends on this
             Knot_Values'Length - Control_Points'Length - 1 > 0; -- At least 0 degree 
   
   function Eval_Catmull_Rom ( Control_Points : in Control_Points_Array;
                               Segment        : in Positive;
                               T              : in Parametrization_Type) return Point_Type;
   
   -- Evaluate f(t) of a function interpolating  {t,f(t)}, where t vlaues are the interpolation nodes.
   -- and f(t) values are control points. The interpolation is done with Lagrange method.
   function Eval_Lagrange( Control_Points      : in Control_Points_Array;
                           Interpolation_Nodes : in Interpolation_Nodes_Array;
                           T                   : in Parametrization_Type) return Point_Type with
     Pre => Control_Points'Length = Interpolation_Nodes'Length;
   
   function Make_Equidistant_Nodes(  N : Positive ) return Interpolation_Nodes_Array;
   
   function Make_Chebyshev_Nodes(  N : Positive )   return Interpolation_Nodes_Array;
   
   
end Curve;
