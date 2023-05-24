%***********************************************************************
* Name: translate.sas                                                  *
* Description: Macro with same functionality as SAS tranlate function  *
* Creation Date: 19/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;

/* --- INPUT : DESCRIPTION ---
         macvar : macro variable to be translated
         symto : characters to translate to
         symfrom : characters to translate from
*/

%macro translate(macvar, symto, symfrom);
	%* Translate macro function;
	%sysfunc(translate(&macvar.,&symto.,&symfrom.))
%mend;