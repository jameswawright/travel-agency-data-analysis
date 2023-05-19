%macro procprint(lib, dat, vars=, byvars=, numobs=, title=);
	%if &title. ne %str() %then title %str("&title."); ; 
	proc print data=&lib..&dat. %if &numobs. ne %str() %then (obs=&numobs.);
    label noobs;
	%if &vars. ne %str() %then %do;
		var &vars.;
	%end;
	%if &byvars. ne %str() %then %do;
		by &byvars.;
	%end;
	run;
	
	%if title ne %str() %then title; ;
%mend;