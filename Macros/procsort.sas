%macro procsort(lib, ds, byvars, keepvars=, nodup=0, desc=0, out_data=work.ds_sorted);
	proc sort data=&lib..&ds. out=&out_data.
		                                     %if &keepvars. ne %str() %then (keep=&keepvars.);
                                             %if &nodup. ne 0 %then nodupkey;
        ;
		by %if &desc. ne 0 %then descending; &byvars.;
	run;
%mend;