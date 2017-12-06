program TestPL2Machinepark;
{$mode objfpc}

//type declarations
TYPE machine=RECORD
	code: string;
end;

//global var declarations

var invoerBestand: file of machine;

var machineRecord, leeg: machine;

//Declare Two Dimensional Arrays
type tweeDimensionaleStatischeArray = array [0..9,0..6] of integer;
var resultaatTabelGoed, resultaatTabelSlecht: tweeDimensionaleStatischeArray;

var aantalFoutieven, i, rijGlobal, kolomGlobal, productNumber, productResult, ErrorCode, margin:integer;


//*******************************************************************************
//This procedure sets all values to 0 for each element within the passed 2d array
//*******************************************************************************
procedure Vul2DArrayAlleElementenMet0(var pArray: tweeDimensionaleStatischeArray);

var kolom, rij: integer;

begin
	//voor elke rij
	for rij := 0 to (LENGTH(pArray)-1) do
	begin
		//per element (van de rij en de onderliggende kolom)
		for kolom := 0 to (LENGTH(pArray[0])-1) do
			begin
				pArray[rij, kolom] := 0;
			end;
	end;
end;

//**********************************
// Print een machine resultaat tabel
//**********************************
procedure CalculateTotalsAndPrintResultsTable(var pArray: tweeDimensionaleStatischeArray);

var rij, kolom: integer;

begin
	//first print the border row elements
	margin := 6;
	writeln(' ':margin, 'A':margin, 'B':margin, 'C':margin, 'D':margin, 'E':margin, 'F':margin, 'TOT':margin);
	
	//voor elke rij
	for rij := 0 to (LENGTH(pArray)-1) do
	begin
		//first print the border column element, and calculates TOT row
		if (rij = 9) then
		begin
			//print row border element
			write('TOT':6);

		end
		else
		begin
			//write border number
			write((rij+1):6);
		end;
		
		//now print the array itself
		//per element (van de rij en de onderliggende kolom)
		for kolom := 0 to (LENGTH(pArray[0])-1) do
			begin
				//if on TOT column, calculate it's value
				if (kolom = 6) then
				begin
					//print total
					write(pArray[rij, 6]:margin)
				end;
				if ( (rij <> 9) and (kolom <> 6) ) then
				begin
					//on each other element, count for total
					write(pArray[rij, kolom]:margin);
					pArray[rij, 6] := pArray[rij, 6] + pArray[rij, kolom];
				end;
				
		        //calculate for last row
				if (rij = 9) then
				begin
					if (kolom <> 6) then
					begin
						//write last row's elements, which are totals of each column
						write(pArray[9, kolom]:margin);
					end;
				end
				else
				begin
					//count for total
					pArray[9, kolom] := pArray[9, kolom] + pArray[rij, kolom];
				end;

			end;
		writeln();
        //writeln();
	end;
	writeln();
end;
//end of procedure


//main program code
begin
	//get file ready for reading
	ASSIGN(invoerBestand, 'machines.txt');
	RESET(invoerBestand);

	Vul2DArrayAlleElementenMet0({var} resultaatTabelGoed);
	Vul2DArrayAlleElementenMet0({var} resultaatTabelSlecht);
	
	aantalFoutieven := 0;
	
	While not EOF(invoerBestand) do
	begin
		Try
			read(invoerBestand, machineRecord); {readln VOOR TEXT, read voor records!}
		Except
			writeln('fout opgetreden bij lezen van lijn ',i);
			readln();
			exit;
		end;
		
		
		//------------------------------------------
		//Validate each character within code string
		//------------------------------------------
		
		//first char
		//							▼<A								▼>F
		if ( (ord(machineRecord.code[1]) < 65) OR (ord(machineRecord.code[1]) > 70) ) then
		begin
			aantalFoutieven := aantalFoutieven + 1;
			continue;
		end;
		
		//second char
		try 
			val(machineRecord.code[2], productNumber, ErrorCode);
		except
			aantalFoutieven := aantalFoutieven + 1;
			continue;
		end;
		if ( ( productNumber < 1) OR ( productNumber > 9) ) then
		begin
			aantalFoutieven := aantalFoutieven + 1;
			continue;
		end;
		
		//third char
		try 
			val(machineRecord.code[3], productResult, ErrorCode);
		except
			aantalFoutieven := aantalFoutieven + 1;
			continue;
		end;
		if ( (productResult <> 0) AND (productResult <> 1) ) then
		begin
			aantalFoutieven := aantalFoutieven + 1;
			continue;
		end;
		{Deze laatse if kon bv in een case opgebroken om onmiddelijk interpretatie te doen 
		 met minder memory reads etc. 
		 Ik vond het beter voor code clarity om in de plaats hiervan het op te breken tussen
		 validatie sectie en interpretatie/opslag sectie.}
		
		
		//-----------------------------------------------------------------------------------------
		//Interpret & store results into one of two arrays depending on last character being 1 or 0
		//-----------------------------------------------------------------------------------------
		
		if ( productResult = 1 ) then
		begin
			{kan omzetten naar een procudure voor beide}
			kolomGlobal := ord(machineRecord.code[1]) - 65;
			rijGlobal := productNumber - 1;
			resultaatTabelGoed[rijGlobal, kolomGlobal] := resultaatTabelGoed[rijGlobal, kolomGlobal] + 1;
		end
		else
		begin
			kolomGlobal := ord(machineRecord.code[1]) - 65;
			rijGlobal := productNumber - 1;
			resultaatTabelSlecht[rijGlobal, kolomGlobal] := resultaatTabelSlecht[rijGlobal, kolomGlobal] + 1;
		end;
		
		//---------------------------------------------------------------------
		//End of operations for current line in file, continueing to next line.
		//---------------------------------------------------------------------
	end;
	//------------------------
	//Done reading, close file
	//------------------------
	
	CLOSE(invoerBestand);
	
	
	//----------------------------------------------------------
	//Calculate & print the 2 result arrays. Also print the tally count of bad codes.
	//----------------------------------------------------------
	writeln('Goede afwerking:');
	writeln('----------------'); {We printen maar 2 lijnen, anders had ik een dynamische functie hiervoor gebruikt.}
	CalculateTotalsAndPrintResultsTable(resultaatTabelGoed);
	
	writeln('Slechte afwerking:');
	writeln('------------------');
	CalculateTotalsAndPrintResultsTable(resultaatTabelSlecht);
	
	writeln('AANTAL FOUT : ', aantalFoutieven);

	writeln();
	writeln('DRUK ENTER');
	readln();
	//end of entire program
end.
