************************************************************************
* Name: travel_agency_data_engineering.sas                             *
* Description: Travel Agency Project Data Import and Cleaning          *
* Creation Date: 06/04/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;

/* Data input files and locations */
*Path to point library to;
%let libpath = &path.\&data_folder.;

* Assigning custdata library;
libname custdata "&libpath.";
* Assigning path variable pointer;
filename extdata "&libpath.";

/* Importing bookings csv data */
data custdata.bookings;
	infile extdata(bookings.csv) firstobs=2 DSD;

	length family_name $ 20 
           brochure_code $ 1 
           room_type $ 10 
           booking_id $ 7
           destination_code $ 2;

	input  family_name $ 
           brochure_code $ 
           room_type $
           booking_id $
           customer_id
           booked_date : date9.
           departure_date : date9.
           duration 
           pax 
           insurance_code 
           holiday_cost : nlmnlgbp8.2
           destination_code $;

	label   booking_id = 'Booking ID'
			customer_id = 'Customer ID'
			family_name = 'Family Name'
			brochure_code = 'Brochure of Destination'
			booked_date = 'Date Customer Booked Holiday'
			departure_date = 'Holiday Departure Date'
			duration = 'Number of Nights'
			pax = 'Number of Customers'
			insurance_code = 'Customer Added Insurance'
			room_type = 'Room Type'
			holiday_cost = 'Total Cost (£) of Holiday'
			destination_code = 'Destination Code';
run;

/* Importing destinations csv data */
data custdata.destinations;
	infile extdata(destinations.csv) firstobs=2 DSD;

	length destination_code $ 2
	       description $ 25;

	input  destination_code $
           description $;

	label  destination_code = 'Destination Code'
		   description = 'Description';
run;

/* Importing households csv data */
data custdata.households;
	infile extdata(households.csv) firstobs=2 DSD;

	length family_name $ 20
           forename $ 15
           title $ 4
           gender $ 1
		   loyalty_id $ 7
           address_1 $ 60
           address_2 $ 60
           address_3 $ 60
           address_4 $ 20
           postcode $ 8
           email1 $ 50
           contact_preference $ 10
           interests $ 20;

	input  customer_id
           family_name $ 
           forename $ 
           title $ 
           gender $ 
           dob : date9.
           loyalty_id $ 
           address_1 $ 
           address_2 $ 
           address_3 $ 
           address_4 $ 
           postcode $ 
           email1 $ 
           contact_preference $
           interests $ 
           customer_startdate : date9.
           contact_date : date9.;

	label  customer_id = 'Customer Identification'
		   postcode = 'Postcode'
		   family_name = 'Family Name'
		   forename = 'Forename'
		   gender = 'Gender'
		   title = 'Title'
		   address_1 = 'Address1'
		   address_2 = 'Address2'
		   address_3 = 'Address3'
	 	   address_4 = 'Address4'
		   customer_startdate = 'Customer Enrolment Date'
		   contact_date = 'Date Customer Last Contacted'
		   dob = 'Date of Birth'
		   contact_preference = 'Customers Contact Preference'
		   loyalty_id = 'Loyalty Identification'
		   interests = 'Customer Interests'
		   email1 = 'Email Address';
run;

/* Importing loyalty tabulated data */
data custdata.loyalty;
	infile extdata(loyalty.dat) firstobs=2 DSD dlm='09'x;

	length loyalty_id $ 7			
           investor_type $ 12;

	input  account_id
           loyalty_id $	
           invested_date : date9.	
           initial_value	
           investor_type $
           current_value;

	label  loyalty_id = 'Loyalty Identification'
		   account_id = 'Customer Account Number'
		   initial_value = 'Initial Share Value'
		   investor_type = 'Type of Investor'
		   current_value = 'Current Share Value'
		   invested_date = 'Investment Date';
run;

/* Creating Interest Coding Dataset for Use Theoretically in Future 
   and because I just typed it and now I don't want to delete it :) */
data custdata.interest_coding;
	infile cards delimiter=',';
	length code $ 1
	       description $ 20;
	input  code $ 
           description $;

	datalines;
A,Mountaineering
K,Mountaineering
L,Mountaineering
B,Water Sports
C,Sightseeing
X,Sightseeing
D,Cycling
E,Climbing
F,Dancing
W,Dancing
H,Hiking
G,Hiking
J,Skiing
M,Snowboarding
N,White Water Rafting
P,Scuba Diving
Q,Scuba Diving
R,Scuba Diving
S,Yoga
T,Mountain Biking
U,Mountain Biking
V,Trail Walking
Y,Trail Walking
Z,Trail Walking
;
run;

/* Producing a PDF of the Metadata for bookings, destinations, households, loyalty */
ods pdf file="&reportdest.";

	* Meta Data Output for Bookings Dataset;
	%proccontents(custdata, bookings, title = Metadata for Holiday Bookings Dataset);
	ods text='When defining the format the bookings dataset, we have assumed an upper-bound of £99,999.99 on holiday cost through intuition. It was necessary to informat all dates with date9, and skip a header on the first line contained in the csv file.';
	
	* Meta Data Output for Bookings Dataset;
	%proccontents(custdata, destinations, title = Metadata for Holiday Destinations Dataset);
	ods text='We assumed descriptions of a maximum length 25, and skipped a header line in the CSV-file read-in.';
	
	* Meta Data Output for Bookings Dataset;
	%proccontents(custdata, households, title = Metadata for Customer Details Dataset);
	ods text='We have chosen the maximum length of Address1 based on the longest street name in London, St Martin-in-the-Fields Church Path, which is 35 characters, plus 15 characters tolerance for "extras" like flat numbers and spaces. We make a similar assumptions for Address2 with 58 characters to accommodate the town Llanfairpwllgwyngyllgogerychwyrndrobwllllantysiliogogogoch. 
It was necessary to informat all dates with date9.';
	
	* Meta Data Output for Bookings Dataset;
	%proccontents(custdata, loyalty, title = Metadata for Loyalty Shares Dataset);
	ods text='It was necessary to informat all dates with date9. We assumed descriptions will be of maximum length 25.';

ods pdf close;

/* Identify unique households by postcode and address_1 and assign a unique id*/
proc sql noprint;
	create table work.unique_household_address as
		select distinct postcode, 
                        address_1
		from custdata.households;
quit;

data work.unique_household_address;
	set work.unique_household_address;
	household_id = _N_;
run;

/* Create custdata.households_detail: household merging many-to-one to get a unique household_id and 
   also sorting by household_id, gender, and dob to compute primary householder later */
proc sql noprint;
	create table custdata.households_detail as
		select h.*,
               uha.household_id
		from custdata.households as h
			 left join
			 work.unique_household_address as uha
		on h.postcode=uha.postcode and h.address_1=uha.address_1
		order by household_id, gender, dob;
	
	/* Utility table for household id creation no longer needed */
	drop table work.unique_household_address;
quit;

*NOTE: NEED TO DO GENDER FROM MR/MRS ABOVE SOMEHOW;

/* Adding new columns to households_detail dataset and 
   creating datasets separating customers by preferred contact method 
   - contact_post and contact_email */
data custdata.households_detail 
     custdata.contact_post(keep=customer_id contact_preference address_1--postcode greeting) 
     custdata.contact_email(keep=customer_id contact_preference email1 greeting);

	set custdata.households_detail;
	by household_id gender dob;
	
	*Cleaning and formatting forename and family_name data;
	forename = propcase(trim(forename), "-");
	family_name = propcase(trim(family_name),"'-");

	* Cleaning and formatting title data, removing trailing dots;
	title = propcase(trim(title));
	if index(title, '.') > 0 then do;
		title = substr(title, 1, length(title)-1); * Remove end dots;
	end;

	* Adding title if missing by gender;
	if missing(title) then do;
		if upcase(gender)='M' then title='Mr';
		else if upcase(gender)='F' then title='Ms';
		else title='';
	end;

	* Adding gender if missing by title;
	if missing(gender) then do;
		if title='Mr' then gender='M';
		else if title='Mrs' then gender='F';
		else gender='';
	end;

	* Assigning primary householder - if oldest female, else oldest male, else oldest in household - equivalent to first gender in household if ordered by gender and dob;
	if first.household_id and first.gender then primary_householder = 1;
	else primary_householder = 0;
	
	* Adding greeting to households data;
	if missing(gender) or missing(forename) or missing(family_name) then greeting=catt('Dear', ' Customer');
	else greeting = catx(' ', "Dear", title, substr(forename,1,1), family_name);
	
	* Output detailed customer data;
	output custdata.households_detail;

	* Separating customers by contact method, only need primary_householder;
	if upcase(contact_preference) = 'E-MAIL' and primary_householder=1 then output custdata.contact_email;
	if upcase(contact_preference) = 'POST' and primary_householder=1 then output custdata.contact_post; 

run;