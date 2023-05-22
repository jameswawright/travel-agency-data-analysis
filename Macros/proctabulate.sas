************************************************************************
* Name: proctabulate.sas                                               *
* Description: Macro to produce a table based on statistics            *
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
*/

%macro proctabulate(lib, dat, stat, vars, class1=, class2=, outdat=, box=, maxdec=8., title=);
	%* Testing dataset loaded successfully, else abort and give error;
	%dsexist(&lib., &dat.);

	%* Title if included, mention classes if included;
	%if title ne %str() %then %do; 
		ods noproctitle;
        title %str(%sysfunc(propcase(" &title.")));
		footnote %str("Produced on &SYSDATE9. by &SYSUSERID..");
	%end;	
	
	%* Proc tabulation, conditioning on number of classes included;
	%* Retain only variables being used in analysis from dataset;
	proc tabulate data=&lib..&dat.(keep=&class1 &class2 &vars.) 
                  %if &outdat. ne %str() %then out=&outdat.(drop=_:);
                  order=formatted;
		var &vars.;
		class &class1. &class2.;
		table (&vars.)*&stat.=''*f=&maxdec.
              %if &class1. ne %str() and &class2. ne %str() %then %do; 
				  ,&class1.=''*&class2.=''
			  %end;
			  %else %if &class1. ne %str() %then ,&class1.='';
			  %else %if &class2. ne %str() %then ,&class2.='';
			  %else;
              / box=&box.;
	run;

	%* Clear title if included;
	%if title ne %str() %then %do;
		ods proctitle;
		title;
		footnote; 
	%end;

%mend;