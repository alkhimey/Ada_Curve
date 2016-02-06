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


package body Curve is 
   
   
   function "+" (Left, Right : in Point_Type) return Point_Type is 
      Result : Point_Type;
   begin
      for I in Result'Range loop
	 Result(I) := Left(I) + Right(I);
      end loop;
      
      return Result;
   end;
   
   function "-" (Left, Right : in Point_Type) return Point_Type is 
      Result : Point_Type;
   begin
      for I in Result'Range loop
	 Result(I) := Left(I) - Right(I);
      end loop;
      
      return Result;
   end;
   
   function "-" (Right : in Point_Type) return Point_Type is 
      Result : Point_Type;
   begin
      for I in Result'Range loop
	 Result(I) := - Right(I);
      end loop;
      
      return Result;
   end;

   
   
   function "*" (Left  : in Point_Type; 
		 Right : in Base_Real_Type ) return Point_Type is
      Result : Point_Type;
   begin      
      for I in Result'Range loop
	 Result(I) := Right * Left(I);
      end loop;
      
      return Result;
   end;
   
   function "*" (Left  : in Base_Real_Type; 
		 Right : in Point_Type ) return Point_Type is 
   begin
      return Right * Left;
   end;
   
   
   function Eval_De_Castelijau( Control_Points : in Control_Points_Array;
				T              : in Parametrization_Type) return Point_Type is   
      Temp_Points : Control_Points_Array := Control_Points;
   begin
      
      for I in 1 .. Control_Points'Length - 1 loop	 
	 for J in Control_Points'First .. Control_Points'Last - I loop
	 
	    Temp_Points(J) := T * Temp_Points(J) + (1.0-T) * Temp_Points(J+1);
	   
	 end loop;
      end loop;
	
      return Temp_Points(Temp_Points'First);
      
   end; 
   
   
   function Eval_De_Boor      ( Control_Points : in Control_Points_Array;
				Knot_Values    : in Knot_Values_Array;
				T              : in Parametrization_Type) return Point_Type is
   begin
      return ORIGIN_POINT;
   end;
   
   function Eval_Catmull_Rom ( Control_Points : in Control_Points_Array;
			       Knot           : in Positive;
			       T              : in Parametrization_Type) return Point_Type is 
      
      P0, P1, P2, P3 : Point_Type;
      
   begin
      
      P0 := Control_Points( Knot );
      P1 := Control_Points( Knot + 1 );
      P2 := Control_Points( Knot + 2 );
      P3 := Control_Points( Knot + 3 );

	
      return 0.5 * (
		    (2.0 * P1) + 
		      T * (-P0 + P2) + 
		      T*T * (2.0 * P0 - 5.0 * P1 + 4.0 * P2 - P3) +
		      T*T*T * (-P0 + 3.0 * P1 - 3.0 * P2 + P3) 
		   );
   end;
   
   
   
begin

   null;
   
end Curve;
