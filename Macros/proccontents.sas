%macro proccontents(lib, dat, title=);
	%if title ne %str() %then title "&title."; ;
	proc contents data=&lib..&dat;
	run;
	%if title ne %str() %then title; ;
%mend;