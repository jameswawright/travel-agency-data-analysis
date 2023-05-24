************************************************************************
* Name: travel_agency_data_engineering.sas                             *
* Description: Travel Agency Project Autoexec Program                  *
* Creation Date: 04/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;

*** USER EDITS DETAILS BELOW ***;

/* Add your path to root of project file */
%let project_path=C:\Users\james.wright\OneDrive - Amadeus Software\Case Studies\Travel Agency;











*------ Do not unintentionally edit below this line ------------------------------------------------------------;

/* Creating paths to different parts of the folder structure */
* Assigning path to original datasets;
%let indata_path = &project_path.\SAS\Data\Inputs;
* Assigning path to point data libraries to;
%let data_path = &project_path.\SAS\Data;
* Assigning path to reports folder;
%let report_path = &project_path.\SAS\Reports;
* Assigning path to shared library;
%let shared_path = &project_path.\SAS\Shared;

/* Autocalling Macro Library */
filename mymacros "&project_path.\SAS\Macros";
* Searching mymacros if macro not found in work library;
options mautosource sasautos=(mymacros, sasautos);

/* Storing default system options to restore later */
data _null_;
	%storeoptval(msglevel); *msglevel option;
	%storeoptval(autocorrect); *autocorrect option;
	%storeoptval(fmtsearch); *fmtsearch option;
run;

/* Other Session Options */
* Output information;
options msglevel=i;
* Formats found in shared file;
options fmtsearch=(shared);
* Turning off autocorrect for safety;
options noautocorrect;