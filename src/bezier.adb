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


package body Bezier is 
   
   
   function "+" (Left, Right : Point_Type) return Point_Type is 
   begin
      return (X => Left( X ) + Right ( X ),
	      Y => Left( Y ) + Right ( Y ));
   end;
   
   function "*" (Left  : Point_Type; 
		 Right : Base_Real_Type ) return Point_Type is
   begin
      return (X => Right * Left( X ) ,
	      Y => Right * Left( Y ));
   end;
   
   function "*" (Left  : Base_Real_Type; 
		 Right : Point_Type ) return Point_Type is 
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
begin
   
   

   
   null;
   
end;
