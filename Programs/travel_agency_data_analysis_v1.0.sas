************************************************************************
* Name: travel_agency_data_analysis.sas                                *
* Description: Travel Agency Project Data Analysis                     *
* Creation Date: 18/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;





*------ Do not unintentionally edit below this line ------------------------------------------------------------;


/* Outputting PDF reports on frequent interests and frequent interests by country and gender */
ods pdf file="&report_path.\ReportC-Interest_Frequencies.pdf" style=Journal;
	* Change report orientation;
	option orientation=landscape;

	* Frequency count report for interests - no need to retain output data for future reporting;
	%proctabulate(custdetl, households_detail, sum, 
                  vars=%sysfunc(translate(&interest.,' ','|')),
				  title=Frequency count for each type of holiday interest, 
                  box=Frequency, 
                  maxdec=8.);
	
	* Frequency count report for interests by country and gender - retaining output data for future reporting;
	%proctabulate(custdetl, households_detail, sum, 
                  vars=%sysfunc(translate(&interest.,' ','|')), 
                  class1=gender,
				  class2=address_4, 
                  outdat=work.freq_interests_byaddress4gender,
				  title=Frequency count for each type of holiday interest by country and gender, 
                  box=Frequency, 
                  maxdec=8.);
ods pdf close;

%* Testing freq_interests_byaddress4gender dataset created successfully, else abort and give error;
%dsexist(work, freq_interests_byaddress4gender);

/* Finding top interests by gender */

* Creating dataset of interests by gender 
   - Transpose retained dataset of interests by gender and country to have frequencies for all interests aligned;
proc transpose data=work.freq_interests_byaddress4gender 
               out=work.freq_interests_bygender(drop=address_4 rename=(_name_=Interest col1=tot));
	by gender address_4;
run;

%* Testing freq_interests_bygender dataset created successfully, else abort and give error;
%dsexist(work, freq_interests_bygender);

* Create a view of sum of frequencies grouped by gender and interest, order by gender and frequency, 
  producing hierarchy of interests by gender;
proc sql noprint;
	create view work.freq_interests_bygenderfreq as
		select gender, interest, sum(tot) as frequency
		from work.freq_interests_bygender
		group by gender, interest
		order by gender, frequency desc;
run;

* Find top 5 interests for female and male from frequency table, order by gender and interest_total;
data work.freq_interests5_bygenderfreq(drop=n keep=gender interest);
	set work.freq_interests_bygenderfreq;
	by gender;

	* Format an interest description from variable name to normal grammar;
	if _N_=1 then prx_sum=prxparse("/\w_sum/i"); *Interests end in _sum now from proc tabulate;
	retain prx_sum;
	call prxsubstr(prx_sum, interest, sum_start, sum_len);
	interest = translate(substr(interest,1,sum_start),' ','_');
	label interest='Top 5 Interests';

	* Select top 5;
	if first.gender=1 then n=1;
	else n+1;
	if n<=5 then output;
run;

%* Testing freq_interests5_bygenderfreq dataset created successfully, else abort and give error;
%dsexist(work, freq_interests5_bygenderfreq);

/* Outputting Top 5 Interests by Gender to Excel*/
ods excel file="&report_path.\ReportC-Top_5_Interests_by_Gender.xlsx"
          options(sheet_interval='bygroup' suppress_bylines='yes' sheet_label='Gender');
	%procprint(work, freq_interests5_bygenderfreq, vars=Interest, byvars=gender, title=Top 5 Interests by Gender);
ods excel close;