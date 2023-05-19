************************************************************************
* Name: travel_agency_data_analysis.sas                                *
* Description: Travel Agency Project Data Analysis                     *
* Creation Date: 18/05/2023                                            *
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
			   %* Make every interest column found in data cleaning an input variable;
	           vars = %do n = 1 %to &numobs.;
					  	&&interest&n
					  %end;
					  ;
			   );
%mend;

/*** Reporting ***/

/* Outputting PDF reports on frequent interests and frequent interests by country and gender*/
ods pdf file="&report_dest.\ReportC.pdf" style=Journal;
	* Frequency count of each type of holiday interest;
	%freq_interests(outdat=work.freq_interests_overall);

	* Frequency count of each type of holiday interest by country and gender, output to table;
	%freq_interests(classes=address_4 gender, outdat=work.freq_interests_byaddress4gender);
ods pdf close;

/* Finding top 5 interest by gender */

* Find top 5 interests for female and male from frequency table, order by gender and interest_total;
proc sql noprint;
	/* Total female interests from existing frequency table, order by gender and interest_total */
	create view work.freq_interests5_byfemale as
		select gender, variable as interest, sum(sum) as interest_total
		from work.freq_interests_byaddress4gender
		where upcase(gender)='F'
		group by gender, variable
		order by gender, interest_total desc;

	/* Total male interests from existing frequency table, order by gender and interest_total */
	create view work.freq_interests5_bymale as
		select gender, variable as interest, sum(sum) as interest_total
		from work.freq_interests_byaddress4gender
		where upcase(gender)='M'
		group by gender, variable
		order by gender, interest_total desc;
quit;

* Append top 5 interests by gender for excel report;
data work.freq_interests5_bygenderinterest;
	set work.freq_interests5_byfemale(obs=5) work.freq_interests5_bymale(obs=5);
	by gender;

	label interest='Interest';
run;

/* Outputting Top 5 Interests by Gender to Excel*/
ods excel file="&report_dest.\ReportC.xlsx"
          options(sheet_interval='bygroup' suppress_bylines='yes' sheet_label='Gender');
	%procprint(work, freq_interests5_bygenderinterest, vars=Interest, byvars=gender, numobs=);
ods excel close;