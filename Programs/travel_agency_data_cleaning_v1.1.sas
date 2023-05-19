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

/* Creating path to shared folder for formats*/
libname shared "&shared_path.";

/* Creating a format to associate gender variables with gender, genderfmt*/
proc format lib=shared;
	value $ genderfmt
	        'M' = 'Male'
			'F' = 'Female'
			'' = 'Missing';
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
proc sql noprint;
	select count(*), translate(trim(description),'_',' '), trim(code)
	into :numobs, :interest1-, :code1-
	from custdata.interest_coding;
quit;

* Macro to produce any number of binary interest columns within a datastep from above macro variables containing interests ;
%macro interest_columns;
	%* For each interest produced in query above;
	%do n = 1 %to &numobs.;
		%* Compile a perl expression pattern number to identify an interest code in string;
		if _N_ = 1 then int_code&n. = prxparse("/&&code&n/");

		%* If interest is in row, assign corresponding variable a 1, else 0;
		if prxmatch(int_code&n.,interests) > 0 then &&interest&n = 1;
		else &&interest&n = 0;
		retain int_code&n.;
		
		drop int_code&n.;
	%end;
%mend;


/* Sorting data by households by postcode address_1 gender dob, to later assign a unique id and primary householder*/
%procsort(custdata, households, byvars=postcode address_1 gender dob, outdat = custstag.households_detail);

/* Creating households_detail dataset - formatting and cleaning existing columns, creating household_id and primary householder columns */
/* Dividing households_detail dataset into contact by post or contact by email datasets*/
/* Creating exceptions dataset if gender and title are both missing */
data custstag.households_detail 
     custstag.contact_post(keep=customer_id contact_preference address_1--postcode greeting) 
     custstag.contact_email(keep=customer_id contact_preference email1 greeting)
     custexcp.gender_title_missing(keep=customer_id);
	
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
	%interest_columns;

	* Output detailed customer data;
	output custstag.households_detail;

	* Separating customers by contact method, only need primary_householder;
	if upcase(contact_preference) = 'E-MAIL' and primary_householder=1 then output custstag.contact_email;
	if upcase(contact_preference) = 'POST' and primary_householder=1 then output custstag.contact_post; 
	
	* Adding labels and formats to table for reporting purposes;
	format gender $ genderfmt.;
run;

/* Moving households_detail data from staging to processed folders and other data management now finished  */
%procdatasets(households_detail, 
              inlib=custstag, outlib=custdetl, copy=1, delete=1);
	

/*** Preparing Booking Data for Analysis ***/

/* Dividing bookings data into datasets of more or less than 6 weeks away*/
data custstag.bookings_deposit custstag.bookings_balance(drop=deposit);
	set custdata.bookings;

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

* Sorting bookings_deposit and bookings_balance by booked_date for reporting purposes;
%procsort(custstag, bookings_deposit, booked_date, outdat = custstag.bookings_deposit);
%procsort(custstag, bookings_balance, booked_date, outdat = custstag.bookings_balance);

/* Moving contact and bookings data from staging to processed folders and other data management now finished  */
%procdatasets(contact_email contact_post bookings_deposit bookings_balance, 
              inlib=custstag, outlib=custmart, copy=1, delete=1);


/*** Data Preparation for Profiling and Analysis ***/

/* Create shareholder and household_only datasets */
proc sql noprint;

	/* Producing shareholder dataset of customers with loyalty_id by inner joining with data from households*/
	create table custstag.shareholders as
		select h.*, l.investor_type, l.account_id, l.invested_date, l.initial_value, l.current_value
		from custdata.loyalty as l
				inner join
		 	custdata.households as h
        on l.loyalty_id = h.loyalty_id;
	
	/* Producing household_only dataset of customers who have not made a booking 
      - Select household data where the customer id does not exist in the bookings dataset */
	create table custstag.household_only as
		select *
		from custdetl.households_detail as hd
		where customer_id not in (select customer_id
		                             from custdata.bookings as b
                                    );
quit;

/* Moving shareholders and household_only data from staging to processed folders and other data management now finished  */
%procdatasets(shareholders household_only, 
              inlib=custstag, outlib=custdetl, copy=1, delete=1);

/*** Reporting ***/
ods pdf file="&report_dest.\ReportB.pdf" style=Journal;
	* Producing a report of bookings_deposit with 30 observations;
	%procprint(custmart, bookings_deposit, numobs=30, title=Most recent 30 bookings that are more than 6 weeks from the departure date.);

	* Producing a report of bookings_balance with 30 observations;
	%procprint(custmart, bookings_balance, numobs=30, title=%str(Most recent 30 bookings that are less than 6 weeks from the departure date.));
ods pdf close;