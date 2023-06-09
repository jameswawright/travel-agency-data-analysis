%***********************************************************************
* Name: proccontents.sas                                               *
* Description: Macro to generate metadata report                       *
* Creation Date: 09/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;

/* --- INPUT : DESCRIPTION ---
         lib : Library
         dat : SAS table for analysis on
       title : Plain text for title
      outdat : SAS table for output of metadata
*/

%macro proccontents(lib, dat, title=, outdat=);
	
	%* Testing dataset loaded successfully, else abort and give error;
	%dsexist(&lib., &dat.);

	%* Make title and footnote if included;
	%if title ne %str() %then %do;
		ods noproctitle;
		title %str(%sysfunc(propcase(" &title."))); 
		footnote %str("Produced on &SYSDATE9. by &SYSUSERID..");
	%end;

	%* Produce metadata header report;
	proc contents data=&lib..&dat %if &outdat. ne %str() %then out=&outdat.;
    ;
	run;
	
	%* Reset title and footnote;
	%if title ne %str() %then %do;
		ods proctitle;
		title; 
		footnote;
	%end;
%mend;