%macro proccopy(sets=, inlib=work, outlib=work);
	proc copy in=&inlib. out=&outlib.;
		%if &sets. = %str() %then %do;
			%put ERROR: Need to selected datasets must be within inlib library;
			%return;
		%end;
		select &sets.;
	run;
%mend;