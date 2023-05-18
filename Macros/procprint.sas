%macro procprint(lib, dat, vars=, numobs=, title=);
	%if &title. ne %str() %then title %str(%"&title.%"); ; 
	proc print data=&lib..&dat. %if &numobs. ne %str() %then (obs=&numobs.);
    label noobs;
	%if &vars. ne %str() %then %do;
		var &vars.;
	%end;
	run;

	title;
%mend;