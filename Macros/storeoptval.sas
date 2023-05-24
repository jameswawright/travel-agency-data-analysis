%***********************************************************************
* Name: storeoptval.sas                                                *
* Description: Macro to store default option values                    *
* Creation Date: 09/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;

/* --- INPUT : DESCRIPTION ---
         opt : Option to be saved
*/

%macro storeoptval(opt);
	%* Get option and save it to macro variable of the same name;
	&opt. = getoption(%unquote(%str(%'&opt.%')));
	call symputx(%unquote(%str(%'&opt.%')),&opt.,'g');
%mend;