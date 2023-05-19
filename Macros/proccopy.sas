************************************************************************
* Name: proccopy.sas                                                   *
* Description: Macro to copy datasets between files                    *
* Creation Date: 18/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;

/* --- INPUT : DESCRIPTION ---
	    sets : Datasets to copy
       inlib : Input Library
      outlib : Output Library
*/

%macro proccopy(sets=, inlib=work, outlib=work);
	proc copy in=&inlib. out=&outlib.;
		%if &sets. = %str() %then %do;
			%put ERROR: Need to selected datasets must be within inlib library;
			%return;
		%end;
		select &sets.;
	run;
%mend;