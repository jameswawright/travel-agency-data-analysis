**************************************************************************************************
* Name: main.sas                                                                                 *
* Description: Travel Agency Project Main Program To Run Other Programs                          *
* V1 Creation Date: 04/05/2023                                                                   *
* Publication Date: 24/05/2023                                                                   *
* Created by: James Wright                                                                       *
*             Katalyze Data Ltd.                                                                 *
**************************************************************************************************;

----------------------------------------------------------Usage--------------------------------------------------------------------
1. Find <path> to root folder Travel Agency.
2. Open autoexec file in Travel Agency / SAS and replace project_path=<path> with own path.
3. Save and run autoexec.sas file.
3. Open and run main_v1.1.sas.

----------------------------------------------------------Folder Structure----------------------------------------------------------

Travel Agency (Root)
	Documents : Case Study PDF Files

	SAS : SAS-Language Related Folders and Programs
		autoexec.sas  : Autoexecution file to set-up SAS environment.
		main_v1.1.sas : Main program to run all study files of study.

		Data : Folders of Data
			Detail     : Folder containing processed datasets.
			Exceptions : Folder containing SAS datasets of missing data observations for review.
			Inputs     : Non-SAS data files.
			Marts      : Subdivision SAS datasets.
			Metadata   : Datasets containing details of SAS datasets.
			Raw        : Unprocessed SAS datasets made from files in Inputs.
			Staging    : Folder containing datasets during processing, should be empty if processed correctly.
		
		Logs : Empty, no logs saved.

		Macros : Folder of general-use macros used in programs.
			dsexist.sas      : Checks for existence of library and dataset before proceeding with code.
			proccontents.sas : Proc contents procedure.
			procdatasets.sas : Proc datasets procedure - copy and delete.
			procprint.sas    : Proc print procedure.
			procsort.sas     : Proc sort procedure.
			proctabulate.sas : Proc tabulate procedure - Formatted tables based on chosen statistics and classes.
			storeoptval.sas  : Code to save default options to macrovariables.
			translate.sas    : Macro function equivalent to SAS translate.

		Programs : Folder of SAS programs
			travel_agency_data_import_v1.0.sas   : Importing Inputs base-datasets to Raw SAS-datasets and Metadata.
			travel_agency_data_cleaning_v1.1.sas : Cleaning and formatting SAS-datasets from Raw into Detail, Missing, and Marts
			travel_agency_data_analysis_v1.0.sas : Data analysis of datasets in Detail/Marts etc.
			restore.sas                          : Restores options to defaults after programs ran.

		Reports : Folder containing output reports.

		Shared : Folder containing formats and functions.

		
