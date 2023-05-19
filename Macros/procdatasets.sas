************************************************************************
* Name: procdatasets.sas                                               *
* Description: Macro to copy and delete datasets between libraries     *
* Creation Date: 19/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;

/* --- INPUT : DESCRIPTION ---
	  select : SAS table to move
       inlib : Library to move from
	  outlib : Library to move to
        copy : Binary value, copy from library if 1, else 0.
      delete : Binary value, delete from library if 1, else 0.
*/

%macro procdatasets(select, inlib=custstag, outlib=work, copy=1, delete=0);
	proc datasets lib=&inlib. nolist;
	%if &copy. = 1 %then %do;
		copy out=&outlib.;
		select &select.;
	%end;

	%if &delete. = 1 %then %do;
		delete &select.;
	%end;
%mend;