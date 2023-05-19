************************************************************************
* Name: procsort.sas                                                   *
* Description: Macro to sort data using proc sort                      *
* Creation Date: 17/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;

/* --- INPUT : DESCRIPTION ---
         lib : Library
         dat : SAS table to sort
        vars : SAS variables to print
      byvars : SAS variables to sort by
       nodup : Binary value, 0 if duplicates allowed, 1 if no duplicates
        desc : Binary value, 0 if ascending, 1 if descending 
               (1 variable only - else set 0 and include descending after a byvar variable)
      outdat : SAS table for output of sorted table
*/

%macro procsort(lib, dat, byvars, keepvars=, nodup=0, desc=0, outdat=work.ds_sorted);
	proc sort data=&lib..&dat. out=&outdat.
		                                     %if &keepvars. ne %str() %then (keep=&keepvars.); %* Keep option;
                                             %if &nodup. ne 0 %then nodupkey; %* Nodupkey option;
        ;
		by %if &desc. ne 0 %then descending; &byvars.; %* Decending option (1 variable);
	run;
%mend;