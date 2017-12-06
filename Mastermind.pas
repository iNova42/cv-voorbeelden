program Mastermind;

{$GOTO ON}

//global var declarations
var getal1, getal2, getal3, getal4, input1, input2, input3, input4, i, totaalW: integer;

// Procedures

// ******************************************************************************
// Schrijft R als de input gelijk is aan huidige pGetal waar men mee vergelijkt,
// bepaald welke pGetal het is aan de hand van i,
// indien geen R vergelijkt het de input met andere 3 pGetal'en voor W
// ******************************************************************************
procedure resultaatRPrint(pGetal1: Longint; pGetal2: Longint; pGetal3: Longint; pGetal4: Longint; pInput: Longint;var TotaalW: Longint;var i: Longint);

	//local in function var declarations
	// none

	begin
		i := i + 1 ;
		//Bepaald welke pGetal men mee vergelijkt voor R
		case (i) of
			1:
			begin
				if (pGetal1 = pInput) then
				begin
					writeln('R');
				end
				else
				begin
					if ( (pInput = pGetal2) or (pInput = pGetal3) or (pInput = pGetal4) ) then
					begin
						totaalW := totaalW + 1;
					end;
				end;
			end;
			2:
			  begin
								if (pGetal2 = pInput) then
				begin
					writeln('R');
				end
				else
				begin
					if ( (pInput = pGetal1) or (pInput = pGetal3) or (pInput = pGetal4)) then
					begin
						totaalW := totaalW + 1;
					end;
				end;
			  end;
			3:
			  begin
				if (pGetal3 = pInput) then
				begin
					writeln('R');
				end
				else
				begin
					if ( (pInput = pGetal1) or (pInput = pGetal2) or (pInput = pGetal4)) then
					begin
						totaalW := totaalW + 1;
					end;
				end;
			  end;
			else
				if (pGetal4 = pInput) then
				begin
					writeln('R');
				end
				else
				begin
					if ( (pInput = pGetal1) or (pInput = pGetal2) or (pInput = pGetal3)) then
					begin
						totaalW := totaalW + 1;
					end;
				end;;
		end;
	end;	
	
//main program code
begin
	Randomize;
	
	//PUT IN A FUNC?
	getal1 := Random(3)+1;
	getal2 := Random(3)+1;
	getal3 := Random(3)+1;
	getal4 := Random(3)+1;
	input1:=0;
    input2:=0;
    input3:=0;
    input4:=0;
        writeln('debug: ',getal1,getal2,getal3,getal4);
	While ((getal1*1000 + getal2*100 + getal3*10 + getal4) <> (input1*1000 + input2*100 + input3*10 + input4)) do
	begin
             i := 0;
             totaalW:=0;
		writeln('Raad de code. Geef 4 cijfers in (kiezen uit 1,2,3 en 4) telkens gescheiden door een spatie');
		readln(input1, input2, input3, input4);
		resultaatRPrint(getal1,getal2, getal3, getal4, input1,{var} totaalW, {var} i);
		resultaatRPrint(getal1,getal2, getal3, getal4, input2,{var} totaalW, {var} i);
		resultaatRPrint(getal1,getal2, getal3, getal4, input3,{var} totaalW, {var} i);
		resultaatRPrint(getal1,getal2, getal3, getal4, input4,{var} totaalW, {var} i);
		for i:= 1 to totaalW do
		begin
			writeln('W');
		end ;
    end;
    writeln('geraden!');
end.
