************************************************************************
* Name: procmeans.sas                                                  *
* Description: Macro to produce a printed report using proc means      *
* Creation Date: 18/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;

/* --- INPUT : DESCRIPTION ---
         lib : Library
         dat : SAS table for analysis on
        vars : SAS variables to compute statistics on
     classes : SAS variables to compute statistics by
         opt : Proc means options
       title : Plain text for title
      outdat : SAS table for output of analysis
      outopt : Output options, such as variable names
*/

%macro procmeans(lib, dat, vars=, classes=, opt=, title=, outdat=, outopt=);
	%* Title if included, mention classes if included;
	%if title ne %str() %then %do; 
        title1 %str("&title.."); 
        %if &classes. ne %str() %then title2 %str("Sub-divided by: &classes.."); ;
		footnote %str("Produced on &SYSDATE9. by &SYSUSERID..");
	%end;

	%* Print report with mean-options, variable, classes, and output data options;
	proc means data=&lib..&dat. %if &opt. ne %str() %then &opt.;
    ;
		%if &vars. ne %str() %then var &vars.; ;
		%if &classes. ne %str() %then class &classes.; ;
		
		%* Output data in ods format or regular format depending on options included;
		%if &outdat. ne %str() and %index(&opt.,stackodsoutput)>0 %then ods output summary=&outdat.;
		%else %if &outdat. ne %str() %then output out=&outdat. &outopt.;
		%else; ;
	run;
	
	%* Clear title if included;
	%if title ne %str() %then %do;
		title;
		footnote; 
	%end;
%mend;