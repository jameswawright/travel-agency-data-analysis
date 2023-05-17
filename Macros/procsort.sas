%macro procsort(lib, ds, byvars, keepvars=, nodup=0, out_data=work.ds_sorted);
	proc sort data=&lib..&ds. out=&out_data.
		                                     %if &keepvars. ne %str() %then (keep=&keepvars.);
                                             %if &nodup. ne 0 %then nodupkey;
        ;
		by &byvars.;
	run;
%mend;