


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
   
   
   --  real^int
   function Exponentiate (Argument : in     Base_Real_Type;
			  Exponent : in     Natural) return Base_Real_Type is
      Result : Base_Real_Type := 1.0;
   begin
      for Counter in 1 .. Exponent loop
	 Result := Result * Argument;
      end loop;
      
      return Result;
   end Exponentiate;
   


   function Binomial_Coeff( N : in Positive;
			    I : in Natural) return Natural is
      
      Res : Natural := 1;
      K : Natural;
   begin
      
      if N = I then
	 return 1;
      end if;
      
      if I < N-I then
	 K := I;
      else
	 K := N-I;
      end if;
      
      for J in Natural range 0 .. K-1 loop
	Res := (Res * (N - J)) / (J + 1);
      end loop;
      
      return Res;
      
   end;

   
   
   function Eval_Bernstein_Basis(N : in Positive;
				 I : in Natural;
				 T : in Parametrization_Type) return Base_Real_Type is
   begin   
	 
      return Base_Real_Type(Binomial_Coeff(N, I)) * Exponentiate(T, I) * Exponentiate(1.0 - T, N - I); 
      
   end;

   
   function Bezier( Control_Points : in Control_Points_Array;
		    T              : in Parametrization_Type) return Point_Type is   
      Res_Point : Point_Type := ORIGIN_POINT;
   begin
      
      for I in Control_Points'Range loop 
	 Res_Point := Res_Point + Control_Points(I) * Eval_Bernstein_Basis(Control_Points_Num-1, I-1, T); 	 
      end loop;
      
      return Res_Point;      
      
   end;
   
begin
   
   

   
   null;
   
end;
