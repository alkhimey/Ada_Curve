--
--
--
--
--
--

generic
   type Base_Real_Type is digits <>; -- Fixed point only
   Control_Points_Num : Positive;   
package Bezier is
   
   
   -- Type Definitions
   -------------------
   
   type Dimension_Type is (X, Y);

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
   
   function Bezier( Control_Points : in Control_Points_Array;
		    T              : in Parametrization_Type) return Point_Type;



end Bezier;
