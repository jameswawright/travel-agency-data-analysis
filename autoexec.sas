************************************************************************
* Name: travel_agency_data_engineering.sas                             *
* Description: Travel Agency Project Autoexec Program                  *
* Creation Date: 04/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;

*** USER EDITS DETAILS BELOW ***;

/* Add your path to project file */
%let project_path = C:\Users\james.wright\OneDrive - Amadeus Software\Case Studies\Travel Agency;


*------ Do not unintentionally edit below this line ------------------------------------------------------------;
/* Assigning path to reports across stages */
%let report_dest = &project_path.\SAS\Reports;

/* Autocalling Macro Library */
filename mymacros "&project_path.\SAS\Macros";
* Searching mymacros if macro not found in work library;
options mautosource sasautos=(mymacros, sasautos);

/* Storing default system options to restore later */
data _null_;
	call symputx('msglvl', 'g');
run;

/* Other Options */
options msglevel=i;