%macro procmeans(lib, dat, vars=, classes=, opt=, title=, outdat=, outopt=);
	%if title ne %str() %then %do; 
        title1 %str("&title.."); 
        %if &classes. ne %str() %then title2 %str("Sub-divided by: &classes.."); ;
	%end;

	proc means data=&lib..&dat. %if &opt. ne %str() %then &opt.;
    ;
		%if &vars. ne %str() %then var &vars.; ;
		%if &classes. ne %str() %then class &classes.; ;

		%if &outdat. ne %str() and %index(&opt.,stackodsoutput)>0 %then ods output summary=&outdat.;
		%else %if &outdat. ne %str() %then output out=&outdat. &outopt.;
		%else; ;
	run;

	%if title ne %str() %then title; ;
%mend;