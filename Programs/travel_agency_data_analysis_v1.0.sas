************************************************************************
* Name: travel_agency_data_analysis.sas                                *
* Description: Travel Agency Project Data Analysis                     *
* Creation Date: 17/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;





*------ Do not unintentionally edit below this line ------------------------------------------------------------;

/* Utility macro to allow variables to be written in from macrovariables interest1- 
   derived in the data_cleaning.sas %interest_columns macro 
     - so proc means can generalise as interests change */
%macro freq_interests(opt=sum nway nonobs maxdec=0 stackodsoutput, classes=, outdat=);
	%procmeans(custdetl, households_detail, 
               opt=&opt., 
               title=Frequency count of each type of holiday interest,
			   %if &classes. ne %str() %then classes=&classes.,;
			   %if &outdat. ne %str() %then outdat=&outdat.,;
	           vars = %do n = 1 %to &numobs.;
					  	&&interest&n
					  %end;
					  ;
			   );
%mend;

/*** Reporting ***/

/* Outputting PDF reports on frequent interests and frequent interests by country and gender*/
ods pdf file="&report_dest.\ReportC.pdf";
	* Frequency count of each type of holiday interest - outputting a frequency count dataset for next question;
	%freq_interests(outdat=work.freq_interests_overall);

	* Frequency count of each type of holiday interest by country and gender;
	%freq_interests(classes=address_4 gender, outdat=work.freq_interests_byaddress4gender);
ods pdf close;

proc sql;
	create table work.freq_interests_bygenderinterest as
		select gender, variable as interest, sum(sum) as interest_total
		from work.freq_interests_byaddress4gender
		group by gender, variable
		order by gender, interest_total desc;
quit;

/* Outputting Top 5 Interests by Gender to Excel*/
ods excel file="&report_dest.\ReportC.xlsx" options(sheet_interval='bygroup' suppress_bylines='yes' sheet_label='gender');
	%procprint(work, freq_interests_bygenderinterest, vars=interest, byvars= gender, numobs=);
ods excel close;