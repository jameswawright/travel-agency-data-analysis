************************************************************************
* Name: travel_agency_data_cleaning.sas                                *
* Description: Travel Agency Project Data Cleaning                     *
* Creation Date: 17/05/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;





*------ Do not unintentionally edit below this line ------------------------------------------------------------;


/*** Creating Formats ***/

/* Creating path to shared folder for storing formats*/
libname shared "&shared_path.";

/* Creating a format to associate gender variables with gender, genderfmt*/
proc format lib=shared;
	value $ genderfmt
	        'M' = 'Male'
			'F' = 'Female'
			' ' = 'Unknown';
run;

/* Creating a format to associate descriptions with destination code, destfmt */
* Formatting table for proc format;
data work.destfmt;
	set custdata.destinations(rename=(destination_code=start description=label));
	fmtname = 'destfmt';
	type = 'C';
run;

* Creating format destfmt;
proc format cntlin=work.destfmt lib=shared;
run;

/*** Preparing Houshold Data for Analysis ***/

/* Produce any number of binary interest columns in household_detail using values from custdata.interest_coding dataset 
   - allows for change of codes and gathered interests in that dataset without the need to change datastep code! :) */
* Storing interests distinctly in macro variables to produce interest binary columns in household_detail in macro below;
* Converting each description to a valid variable name interest1, interest2, etc;
proc sql noprint;
	select count(*), translate(trim(description),'_',' '), trim(interest_code), trim(description)
	into :numobs, :interest separated by '|', :code1-, :description separated by '|'
	from custdata.interests;
quit;

* Macro to produce any number of binary interest columns within a datastep from above macro variables containing interests ;
* interest_error_ds is going to be a dataset to store non-missing interest codes that are not valid interest codes from above, as exceptions;
%let interest_error_ds = interest_code_error;
%macro interest_columns(interest_error_ds);
	%* For each interest produced in query above;
	%do n = 1 %to &numobs.;
		%* Compile a perl expression pattern number to identify an interest code in string;
		if _N_ = 1 then int_code&n. = prxparse("/&&code&n/"); *&&code&n is stored as e.g. O|M|G;

		%* If interest is in row, assign corresponding interest variable a 1, else 0;
		if prxmatch(int_code&n.,interests) > 0 then %qscan(&interest.,&n.,|) = 1;
		else %qscan(&interest.,&n.,|)  = 0;
		retain int_code&n.;
		
		%* Labels for variables;
		label %qscan(&interest.,&n.,|) = %qscan(&description.,&n.,|);
		
		drop int_code&n.;

		%* Generate a list of all known interest codes to find erroneous interest codes to raise as exceptions;
		%if &n. = 1 %then %let codes = &&code&n;
		%else %let codes = %sysfunc(catx(|,&codes.,&&code&n));
	%end;
	
	%*Search for interest codes that do not match an interest description and are not missing;
	%* Compile a perl expression pattern number to identify an interest code in string;
	if _N_ = 1 then int_codes = prxparse("/&codes.|\s*/"); *Search for all allowable codes or empty interests;
	if prxmatch(int_codes, interests) = 0 then output custexcp.&interest_error_ds.; *If not allowable store in exceptions folder;
	retain int_codes;
	drop int_codes;

%mend;

/* Sorting data by households by postcode address_1 gender dob, to later assign a unique id and primary householder
   - removing potential duplicates on sort for potential analysis purposes as all rows should be unique */
%procsort(custdata, households, byvars=postcode address_1 gender dob, outdat = custstag.households_detail, nodup=1);

/* Creating households_detail dataset - formatting and cleaning existing columns, creating household_id and primary householder columns */
/* Dividing households_detail dataset into contact by post or contact by email datasets*/
/* Creating exceptions datasets if gender and title are both missing, or interest code found that does not match an interest description */
data custstag.households_detail 
     custstag.contact_post(keep=customer_id contact_preference address_1--postcode greeting) 
     custstag.contact_email(keep=customer_id contact_preference email1 greeting)
     custexcp.gender_title_missing(keep=customer_id)
	 custexcp.&interest_error_ds.(keep=customer_id interests);
	
	* Import data by postcode address_1 gender dob to allow creation of household_id and primary_householder;
	set custstag.households_detail;
	by postcode address_1 gender dob;

	* Propcase family_name and forename including over common separators;
	family_name = propcase(trim(family_name),"'-");
	forename = propcase(trim(forename),"-");

	* Propcase title, and if title is missing guess it by gender, remove dots;
	if missing(title)=1 and upcase(gender) = 'M' then title='Mr';
	else if missing(title)=1 and upcase(gender) = 'F' then title='Ms';
	else title=compress(propcase(trim(title)),'.');

	* Capitalise gender, and if gender is missing guess it by title;
	if _N_ = 1 then prx_f = prxparse("/m.*s|lady|m.*m/i"); * Look for miss, mrs, ms, lady, madam;
	if _N_ = 1 then prx_m = prxparse("/m.*r|lordd|sir/i"); * Look for mr, master, lord, sir;
	retain prx_f prx_m;
	if missing(gender) and prxmatch(prx_f,title) > 0 then gender = 'F';
	else if missing(gender) and prxmatch(prx_m,title) > 0 then gender = 'M';
	else gender=upcase(gender);
	drop prx_f prx_m;
	
	* If still missing gender and title, output customer_id to exceptions to check in future;
	if missing(gender)=1 and missing(title)=1 then output custexcp.gender_title_missing;

	* Assigning unique household_id for each address 
	   - First ordered household member chooses a household_id, the rest copy the previous household members id until a new household;
	if first.address_1 = 1 then household_id = _N_;
	past_id = lag(household_id);
	if first.address_1 = 0 then household_id = past_id;
	drop past_id;

	* Assigning primary householder - if oldest female, else oldest male, else oldest in household 
	   - equivalent to first gender in household if ordered by gender and dob;
	if first.address_1=1 and first.gender=1 then primary_householder = 1;
	else primary_householder = 0;

	* Adding greeting to households data;
	if missing(forename) or missing(family_name) or missing(gender) then greeting=catt('Dear', ' Customer');
	else greeting = catx(' ', "Dear", title, substr(forename,1,1), family_name);

	/* Computing interest variable binary columns from interest variable */
	* Add interest columns using macro defined above;
	* Store invalid interest codes that do not match an interest description
	  and are not missing in exceptions dataset interest_code_error;
	%interest_columns(&interest_error_ds.);

	* Output detailed customer data;
	output custstag.households_detail;

	* Separating customers by contact method, only need primary_householder;
	if upcase(contact_preference) = 'E-MAIL' and primary_householder=1 then output custstag.contact_email;
	if upcase(contact_preference) = 'POST' and primary_householder=1 then output custstag.contact_post; 
	
	* Adding labels and formats to table for reporting purposes;
	format gender $ genderfmt.;
run;

%* Testing households_detail created successfully, else abort and give error;
%dsexist(custstag, households_detail);

/* Moving households_detail data from staging to processed folders and other data management now finished  */
%procdatasets(households_detail, 
              inlib=custstag, outlib=custdetl, copy=1, delete=1);

/*** Preparing Booking Data for Analysis ***/

/* Dividing bookings data into datasets of more or less than 6 weeks away*/
data custstag.bookings_deposit custstag.bookings_balance(drop=deposit);
	set custdata.bookings;

	* Spelling correction;
	if index(upcase(room_type),'PP')>0 then room_type='Triple'; 

	* Creating bookings_deposit containing bookings more than 6 weeks away, and deposit and balance values;
	if intck('day', booked_date, departure_date) > 42 then do; 
		deposit = holiday_cost*0.2;
		balance = holiday_cost - deposit;
		output custstag.bookings_deposit;
	end;
	* Creating bookings_balance containing books less than 6 weeks away with balance value;
	else do;
		balance = holiday_cost;
		output custstag.bookings_balance;
	end;

	* Adding labels and formats to table for reporting purposes;
	label destination_code = 'Destination'
          deposit = 'Deposit Paid (£) for Holiday'
          balance = 'Balance Paid (£) for Holiday';
	format destination_code $ destfmt.
           balance nlmnlgbp8.2
           deposit nlmnlgbp8.2;
run;

* Sorting bookings_deposit and bookings_balance by booked_date for reporting purposes 
  - removing potential duplicates from report data on sort for analysis purposes;
%procsort(custstag, bookings_deposit, booked_date, outdat = custstag.bookings_deposit, nodup=1);
%procsort(custstag, bookings_balance, booked_date, outdat = custstag.bookings_balance, nodup=1);

%* Testing bookings datasets created successfully, else abort and give error;
%dsexist(custstag, bookings_deposit);
%dsexist(custstag, bookings_balance);

/* Moving contact and bookings data from staging to processed folders and other data management now finished  */
%procdatasets(contact_email contact_post bookings_deposit bookings_balance, 
              inlib=custstag, outlib=custmart, copy=1, delete=1);


/*** Data Preparation for Profiling and Analysis ***/

/* Create shareholder and household_only datasets */
proc sql noprint;

	/* Producing shareholder dataset of customers with loyalty_id by inner joining with data from households
       - allow potential duplicate rows as more than 1 investment may plausibly be made on a given day by the same person */
	create table custstag.shareholders as
		select h.*, l.investor_type, l.account_id, l.invested_date, l.initial_value, l.current_value
		from custdata.loyalty as l
				inner join
		 	custdata.households as h
        on l.loyalty_id = h.loyalty_id;
	
	/* Producing household_only dataset of customers who have not made a booking 
      - Select non-duplicated household data where the customer id does not exist in the bookings dataset */
	create table custstag.household_only as
		select distinct *
		from custdetl.households_detail as hd
		where customer_id not in (select customer_id
		                             from custdata.bookings as b
                                    );
quit;

%* Testing datasets shareholders and household_only created successfully, else abort and give error;
%dsexist(custstag, shareholders);
%dsexist(custstag, household_only);

/* Moving shareholders and household_only data from staging to processed folders and other data management now finished  */
%procdatasets(shareholders household_only, 
              inlib=custstag, outlib=custdetl, copy=1, delete=1);

/*** Reporting ***/
ods pdf file="&report_path.\ReportB-Bookings.pdf" style=Journal;
	* Change report orientation;
	option orientation=landscape;
	* Producing a report of bookings_deposit with 30 observations;
	%procprint(custmart, bookings_deposit, numobs=30, title=Most recent 30 bookings that are more than 6 weeks from the departure date);

	* Producing a report of bookings_balance with 30 observations;
	%procprint(custmart, bookings_balance, numobs=30, title=%str(Most recent 30 bookings that are less than 6 weeks from the departure date));
ods pdf close;