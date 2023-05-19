%macro proccontents(lib, dat, title=, outdat=);
	%if title ne %str() %then title %str("&title."); ;
	proc contents data=&lib..&dat %if &outdat. ne %str() %then out=&outdat.;
    ;
	run;
	%if title ne %str() %then title; ;
%mend;