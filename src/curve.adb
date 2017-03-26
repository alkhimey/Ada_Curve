--  The MIT License (MIT)
--
--  Copyright (c) 2015-2017 artium@nihamkin.com
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

with Ada.Numerics;

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


   -- De Boor algorithm taken from here:
   --     http://www.cs.mtu.edu/~shene/COURSES/cs3621/NOTES/spline/B-spline/de-Boor.html
   --
   --  If u lies in [uk,uk+1) and u != uk, let h = p (i.e., inserting u p times) and s = 0; 
   --  If u = uk and uk is a knot of multiplicity s, let h = p - s (i.e., inserting u p - s times); 
   --  Copy the affected control points Pk-s, Pk-s-1, Pk-s-2, ..., Pk-p+1 and Pk-p to a new array and rename them as Pk-s,0, Pk-s-1,0, Pk-s-2,0, ..., Pk-p+1,0; 
   --  
   --  for r := 1 to h do 
   --     for i := k-p+r to k-s do  
   --        Let ai,r = (u - ui) / ( ui+p-r+1 - ui ) 
   --        Let Pi,r = (1 - ai,r) Pi-1,r-1 + ai,r Pi,r-1 
   --  Pk-s,p-s is the point C(u).
   --
   -- Assumption: Knot_Values is sorted
   --
   function Eval_De_Boor      ( Control_Points        : in Control_Points_Array;
                                Knot_Values           : in Knot_Values_Array;
                                T                     : in Parametrization_Type;
                                Is_Outside_The_Domain : out Boolean) return Point_Type is
      
      subtype Knot_Index_Type is Positive range Knot_Values'Range;

      Degree : constant Natural := Knot_Values'Length - Control_Points'Length - 1;

      function Alpha( I,R : in Knot_Index_Type) return Parametrization_Type is
      begin
         return (T - Knot_Values(I)) / (Knot_Values(I + Degree - R + 1) - Knot_Values(I));
      end Alpha;

      -- Intermidiate values 
      --
      type P_Type is array
         ( Knot_Index_Type, 
           Natural range 0 .. Degree) of Point_Type;
      
      
      H : Natural := Degree;
      S : Natural := 0;
      K : Knot_Index_Type;
      P : P_Type := (others => (others => Point_Type'(others => 0.0) ) );
      
      
      
   begin
      -- Check if T is inside the domain
      --
      if T < Knot_Values( Knot_Values'First + Degree) or else 
         T > Knot_Values( Knot_Values'Last  - Degree) then
      
          Is_Outside_The_Domain := True;
          return ORIGIN_POINT;
         
      else
         Is_Outside_The_Domain := False;
      end if;
      
      --  Determine knot segment and required multiplicty
      --
      K := Knot_Values'Last; -- TODO: Is this correct?
      
      for I in Knot_Values'First .. Knot_Values'Last loop
         -- Notice: If T = Knot_Values( I ) and I is a multiple knot we want the index
         --         of the last knot in the multiplicity. Therfore the loop is not terminated.
         if I < Knot_Values'Last and then Knot_Values( I + 1 ) > T and then T >= Knot_Values( I ) then
            K := I;
         end if;        
      end loop;
      
      -- Calculate multiplicity
      --
      declare
         Multiplicity : Natural := 0;
      begin 
      
         for I in Knot_Values'Range loop
            if Knot_Values( I ) = T then
               Multiplicity := Multiplicity + 1;
            end if;   
         end loop;
      
         if Multiplicity > Degree then
            -- TODO: Should we seperate Degree and the rest?
            --return Control_Points
            H := 0;
            S := Degree;
         else
            H := Degree - Multiplicity;
            S := Multiplicity;
         end if;
      end;
      
      
      -- Prepare the points
      --
      for I in Knot_Index_Type range K - Degree .. K - S loop
         P(I, 0) := Control_Points( I + Knot_Values'First - Control_Points'First ); 
      end loop;
      
      -- Preform knot insertion H times
      --
      for R in Knot_Index_Type range 1 .. H loop
         for I in Knot_Index_Type range K - Degree + R .. K - S loop
            declare
               A : Parametrization_Type := Alpha(I, R);
            begin
               P(I, R) := (1.0-A) * P(I-1, R-1) + A * P(I,R-1); 
            end;
         end loop;
      end loop;
      
      -- Return the result
      --
      return P(K-S, Degree-S);
   end;

   
   function Eval_Catmull_Rom ( Control_Points : in Control_Points_Array;
                               Segment        : in Positive;
                               T              : in Parametrization_Type) return Point_Type is 
      
      P0, P1, P2, P3 : Point_Type;
      
   begin
      
      P0 := Control_Points( Segment );
      P1 := Control_Points( Segment + 1 );
      P2 := Control_Points( Segment + 2 );
      P3 := Control_Points( Segment + 3 );

        
      return 0.5 * (
                    (2.0 * P1) + 
                      T * (-P0 + P2) + 
                      T*T * (2.0 * P0 - 5.0 * P1 + 4.0 * P2 - P3) +
                      T*T*T * (-P0 + 3.0 * P1 - 3.0 * P2 + P3) 
                   );
   end;
   
   
   function Eval_Lagrange( Control_Points      : in Control_Points_Array;
                           Interpolation_Nodes : in Interpolation_Nodes_Array;
                           T                   : in Parametrization_Type) return Point_Type is
   
      Result : Point_Type := ORIGIN_POINT;

      subtype Interpolation_Nodes_Index_Type is Positive range Interpolation_Nodes'Range;

      function Eval_Basis_Poly(J : in Interpolation_Nodes_Index_Type)  return Base_Real_Type is 
         
         D : constant  Base_Real_Type := (Parametrization_Type'Last - Parametrization_Type'First) / Base_Real_Type(Control_Points'Length - 1);
         
         Numentator   : Base_Real_Type := 1.0;
         Denominator  : Base_Real_Type := 1.0;
      
      begin
         
         for M in Control_Points'Range loop
            
            if M /= J then
               Numentator  := Numentator  * (  T                     - Interpolation_Nodes(M) );
               
               Denominator := Denominator * ( Interpolation_Nodes(J) - Interpolation_Nodes(M) );
            end if;
         
         end loop;
           
         return Numentator / Denominator;
         
      end Eval_Basis_Poly;
        
   begin
      
      for I  in Control_Points'Range  loop
        
         Result := Result + Control_Points(I) * Eval_Basis_Poly(I);
         
      end loop;
      
      return Result;        
         
   end Eval_Lagrange;
   
   
   function Make_Equidistant_Nodes( N : Positive ) return Interpolation_Nodes_Array is 
      
      D : constant  Base_Real_Type := (Parametrization_Type'Last - Parametrization_Type'First) / Base_Real_Type(N - 1);
      Res : Interpolation_Nodes_Array(1..N);
      
   begin
      
      Res(Res'First) := Parametrization_Type'First;
      
      if N /= 1 then
         
         for I in Res'First + 1 .. Res'Last - 1 loop
            
            Res(I) := Parametrization_Type'First + D * Base_Real_Type(I-1);
            
         end loop;
         
         Res(Res'Last) := Parametrization_Type'Last;
         
      end if;
      
      return Res;
      
   end;
   
   
   function Make_Chebyshev_Nodes( N : Positive )   return Interpolation_Nodes_Array is 
      Res : Interpolation_Nodes_Array(1..N);
   begin
      Res := (others => 0.0);
      
               for K in Res'Range loop
            
             Res(K) := 0.5 * (Parametrization_Type'First + Parametrization_Type'Last) + 

              0.5 * (Parametrization_Type'Last - Parametrization_Type'First) * 
              Base_Type_Math.Cos( Ada.Numerics.PI *  Base_Real_Type(2*K - 1)  / Base_Real_Type(2*N) );
    
         end loop;
         
      return Res;
   end;

   
begin

   null;
   
end Curve;
