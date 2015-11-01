--  The MIT License (MIT)
--
--  Copyright (c) 2015 artium@nihamkin.com
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

generic
   type Base_Real_Type is digits <>; -- Floating point only
   Control_Points_Num : Positive;   
package Bezier is
   
   
   -- Type Definitions
   -------------------
   
   type Dimension_Type is (X, Y); -- Can be changed to a 3D curve

   type Point_Type is array( Dimension_Type ) of Base_Real_Type;
   
   subtype Parametrization_Type is Base_Real_Type range 0.0 .. 1.0;
   
   type Control_Points_Array is array(Integer range 1..Control_Points_Num) of Point_Type;
   
   -- Constants
   ------------
   
   ORIGIN_POINT : Point_Type := 
     (X => Base_Real_Type(0.0), 
      Y => Base_Real_Type(0.0));
   
   
   -- Operator definitions
   -----------------------
   
   function "+" (Left, Right : Point_Type) return Point_Type;
   function "*" (Left  : Point_Type; 
		 Right : Base_Real_Type ) return Point_Type;
   
   function "*" (Left  : Base_Real_Type; 
		 Right : Point_Type ) return Point_Type;
   
   
   
   
   -- Curve functions and procedures
   ---------------------------------
   
   function Eval_De_Castelijau( Control_Points : in Control_Points_Array;
				T              : in Parametrization_Type) return Point_Type;

end Bezier;
