%***********************************************************************
* Name: dsexist.sas                                                    *
* Description: Macro to test for existence of library and data         *
* Creation Date: 24/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;

/* --- INPUT : DESCRIPTION ---
         lib : Library
         dat : SAS table for analysis on
*/

%macro dsexist(lib, dat);
	%* If dataset or library does not exist then abort and message;
	%if %sysfunc(exist(&lib..&dat.)) = 0 %then %do;
		%put %str(ERROR: LIBRARY OR DATASET DOES NOT EXIST OR FAILED TO LOAD);
		%put %str(ERROR: TERMINATING EXECUTION.);
		%abort;
	%end;
	%* Successful;
	%else %put %quote(NOTE: The dataset &lib..&dat. successfully found and used.);
%mend;