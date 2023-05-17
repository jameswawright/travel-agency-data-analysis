************************************************************************
* Name: travel_agency_data_cleaning.sas                                *
* Description: Travel Agency Project Data Cleaning                     *
* Creation Date: 06/04/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;

/*** Preparing Houshold Data for Analysis ***/

/* Identifying unique households by postcode and address_1 and assign a unique id*/
* Identify unique households;
proc sql noprint;
	create table work.unique_household_address as
		select distinct postcode, 
                        address_1
		from custdata.households;
quit;

* Assign a unique household ID to those unique households;
data work.unique_household_address;
	set work.unique_household_address;
	household_id = _N_;
run;

/* Creating custstag.households_detail in staging folder: Data cleaning existing columns as imported */ 
/* Merging custdata.households many-to-one with work.unique_household_address to get a unique household_id */
/* Sorting by household_id, gender, and dob to compute a primary_householder in later step */
proc sql noprint;
	create table custstag.households_detail as
		select 
               /* propcase family_name and forename including over common separators */
			   propcase(trim(h.family_name),"'-") as family_name,
			   propcase(trim(h.forename),"-") as forename,
			   /* If missing title, guess title by gender. Else, propcase title anyway and remove '.' */
			   case 
			      when h.title is missing and upcase(h.gender) = 'M' then 'Mr'
				  when h.title is missing and upcase(h.gender) = 'F' then 'Ms'
				  else compress(propcase(trim(h.title)),'.')
			   end as title,
               /* If missing gender, guess gender by title. Else, upcase gender anyway. */
               /* This must be done at this stage as we are ordering the dataset by gender at the end */
			   case
			      when h.gender is missing and upcase(title)='MR' then 'M'
				  when h.gender is missing and upcase(title) in ('MRS','MISS','MS') then 'F'
				  else upcase(h.gender)
			   end as gender,
               /* Making imported columns look better with case, removing outer blanks */
			   upcase(trim(h.loyalty_id)) as loyalty_id,
			   propcase(trim(h.address_1)) as address_1,
			   propcase(trim(h.address_2)) as address_2,
			   propcase(trim(h.address_3)) as address_3,
			   propcase(trim(h.address_4)) as address_4,
			   upcase(trim(h.postcode)) as postcode,
			   lowcase(trim(email1)) as email1,
			   trim(h.contact_preference) as contact_preference,
			   upcase(trim(h.interests)) as interests,
			   h.customer_id as customer_id,
			   h.dob as dob,
			   h.customer_startdate as customer_startdate,
			   h.contact_date as contact_date,
               uha.household_id as household_id
		from custdata.households as h
			 left join
			 work.unique_household_address as uha
		on h.postcode=uha.postcode and h.address_1=uha.address_1
		order by household_id, gender, dob;
	
	/* Utility table for household id creation no longer needed */
	drop table work.unique_household_address;
quit;

/* Storing interests in macro variables as a variable_name for creation of interest binary columns below */
proc sql noprint;
	select translate(lowcase(trim(description)), '_', ' ')
	into : interests separated by ','
	from custdata.interest_coding;
quit;

/* Deriving new columns greeting, primary_householder, and interests to households_detail dataset
   and creating datasets separating customers by preferred contact method 
   - contact_post and contact_email */
data custstag.households_detail 
     custstag.contact_post(keep=customer_id contact_preference address_1--postcode greeting) 
     custstag.contact_email(keep=customer_id contact_preference email1 greeting);

	set custstag.households_detail;
	by household_id gender dob;

	* Adding greeting to households data;
	if missing(gender) or missing(forename) or missing(family_name) then greeting=catt('Dear', ' Customer');
	else greeting = catx(' ', "Dear", title, substr(forename,1,1), family_name);

	* Assigning primary householder - if oldest female, else oldest male, else oldest in household 
	   - equivalent to first gender in household if ordered by gender and dob;
	if first.household_id and first.gender then primary_householder = 1;
	else primary_householder = 0;

	/* Creating customer interest columns for analysis */
	
	* Output detailed customer data;
	output custstag.households_detail;

	* Separating customers by contact method, only need primary_householder;
	if upcase(contact_preference) = 'E-MAIL' and primary_householder=1 then output custstag.contact_email;
	if upcase(contact_preference) = 'POST' and primary_householder=1 then output custstag.contact_post; 

run;

/* Moving data from staging to processed folders */

* Moving from custstag folder into detail and marts folders*;
%proccopy(sets=households_detail, inlib=custstag, outlib=custdetl);
* Copying contact_email and contact_post;
%proccopy(sets=contact_email contact_post, inlib=custstag, outlib=custmart);

/* Deleting staging datasets as completed data processing */
proc datasets lib=custstag nolist;
	delete households_detail contact_email contact_post;
quit;
	
/*** Preparing Booking Data for Analysis ***/