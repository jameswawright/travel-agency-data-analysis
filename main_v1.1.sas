**************************************************************************************************
* Name: travel_agency_data_engineering.sas                                                       *
* Description: Travel Agency Project Main Program To Produce Reports and Perform Analysis        *
* Creation Date: 04/05/2023                                                                      *
* Created by: James Wright                                                                       *
*             Graduate Programmer                                                                *
*             Katalyze Data Ltd.                                                                 *
**************************************************************************************************;

*------ Do not unintentionally edit below this line ------------------------------------------------------------;

/* Program for Data Import of Travel Agency Data */
%include "&project_path.\SAS\Programs\travel_agency_data_import_v1.0.sas";

/* Program for Transform of Travel Agency Data */
%include "&project_path.\SAS\Programs\travel_agency_data_cleaning_v1.0.sas";

/* Program for  Analysis of Travel Agency Data */
%include "&project_path.\SAS\Programs\travel_agency_data_analysis_v1.0.sas";