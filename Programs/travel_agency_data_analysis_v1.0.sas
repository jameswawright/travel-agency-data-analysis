************************************************************************
* Name: travel_agency_data_analysis.sas                                *
* Description: Travel Agency Project Data Analysis                     *
* Creation Date: 17/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;

/*** Reporting ***/
ods pdf file="&report_dest.\ReportC.pdf";
	* Frequency count of each type of holiday interest by gender;
	proc means data=custdetl.households_detail sum nway nonobs maxdec=0;
		var Mountaineering--Trail_Walking;
		class gender;
		output out=work.interestmeans_bygender sum=freq;
	run;

/*	proc sql;*/
/*		create table work.interests_bygender as */
/*			select gender, sum(&interest1.) as int1, sum(&interest2.) as int2*/
/*			from custdetl.households_detail*/
/*			group by gender;*/
/**/
/*		create table work.interests_byaddress4 as */
/*			select address_4, sum(&interest1.) as int1, sum(&interest2.) as int2*/
/*			from custdetl.households_detail*/
/*			group by address_4;*/
/*	quit;*/
	
	* Frequency count of each type of holiday interest by country;
	proc means data=custdetl.households_detail sum nway nonobs maxdec=0;
		var Mountaineering--Trail_Walking;
		class address_4;
		output out=work.interestmeans_bycountry sum=freq;
	run;
ods pdf close;

ods excel file="&report_dest.\ReportC.xlsx" options(sheet_interval='bygroup' suppress_bylines='yes' sheet_label='gender');
	proc sql noprint;
		select freq
		from work.interestmeans_bycountry
		order by gender;
	quit;
ods excel close;