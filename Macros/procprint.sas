************************************************************************
* Name: procprint.sas                                                  *
* Description: Macro to produce a printed report using proc print      *
* Creation Date: 17/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;

/* --- INPUT : DESCRIPTION ---
         lib : Library
         dat : SAS table for analysis on
        vars : SAS variables to print
      byvars : SAS variables to print by
      numobs : Integer number of observations to output
       title : Plain text for title
*/

%macro procprint(lib, dat, vars=, byvars=, numobs=, title=);
	* Testing dataset loaded successfully, else abort and give error;
	%dsexist(&lib., &dat.);

	%* Title if included;
	%if &title. ne %str() %then %do; 
		ods noproctitle;
		title %str(%sysfunc(propcase(" &title.")));
		footnote %str("Produced on &SYSDATE9. by &SYSUSERID..");
	%end; 
	
	%* Print report with variable, observation, and with 'by' options;
	proc print data=&lib..&dat.(keep=&vars. &byvars. %if &numobs. ne %str() %then obs=&numobs.;)
    label noobs;
	%if &vars. ne %str() %then %do;
		var &vars.;
	%end;
	%if &byvars. ne %str() %then %do;
		by &byvars.;
	%end;
	run;
	
	* Clear title if included;
	%if title ne %str() %then %do;
		ods proctitle;
		title; 
		footnote;
	%end;
%mend;