************************************************************************
* Name: travel_agency_data_import.sas                                  *
* Description: Travel Agency Project Data Import                       *
* Creation Date: 06/04/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;





*------ Do not unintentionally edit below this line ------------------------------------------------------------;

/* Defining data input files and locations */
* Assigning path variable pointer to input data folder;
filename extdata "&indata_path.";

/* Definine SAS data files, libraries, and locations */
* Assigning custdata library for raw data;
libname custdata "&data_path.\Raw";
* Assigning staging data library for cleaning data in;
libname custstag "&data_path.\Staging";
* Assigning detail data library for cleaned data;
libname custdetl "&data_path.\Detail";
* Assigning marts data library for data subsets;
libname custmart "&data_path.\Marts";
* Assigning exceptions data library for exceptional values;
libname custexcp "&data_path.\Exceptions";
* Assigning metadata data library for metadata;
libname custmeta "&data_path.\Metadata";

/* Importing data to SAS datasets */
* Importing bookings csv data;
data custdata.bookings;
	* Import file to table;
	infile extdata(bookings.csv) firstobs=2 DSD;
	
	* Defining variable lengths for table;
	length family_name      $ 30 
           brochure_code    $ 1 
           room_type        $ 9 
           booking_id       $ 7
           destination_code $ 2;
	
	* Inputting data variables to import;
	input  family_name      $ 
           brochure_code    $ 
           room_type        $
           booking_id       $
           customer_id
           booked_date      : date9.
           departure_date   : date9.
           duration 
           pax 
           insurance_code 
           holiday_cost     : nlmnlgbp8.2
           destination_code $;

	* Adding labels to variables;
	label   booking_id       = 'Booking ID'
			customer_id      = 'Customer ID'
			family_name      = 'Family Name'
			brochure_code    = 'Brochure of Destination'
			booked_date      = 'Date Customer Booked Holiday'
			departure_date   = 'Holiday Departure Date'
			duration         = 'Number of Nights'
			pax              = 'Number of Customers'
			insurance_code   = 'Customer Added Insurance'
			room_type        = 'Room Type'
			holiday_cost     = 'Total Cost (£) of Holiday'
			destination_code = 'Destination Code';
	
	* Defining formats for variables;
	format booked_date    DDMMYY10.
	       departure_date DDMMYY10.
		   holiday_cost   nlmnlgbp8.2;
run;

%* Testing dataset loaded successfully, else abort and give error;
%dsexist(custdata, bookings);

* Importing destinations csv data;
data custdata.destinations;
	* Import file to table;
	infile extdata(destinations.csv) firstobs=2 DSD;

	* Defining variable lengths for table;
	length destination_code $ 2
	       description      $ 25;

	* Defining variables for import;
	input  destination_code $
           description      $;

	* Adding labels to variables;
	label  destination_code = 'Destination Code'
		   description      = 'Description';
run;

%* Testing dataset loaded successfully, else abort and give error;
%dsexist(custdata, destinations);

* Importing households csv data;
data custdata.households;
	* Import file to table;
	infile extdata(households.csv) firstobs=2 DSD;

	* Defining variable lengths for table;
	length family_name        $ 30
           forename           $ 15
           title              $ 4
           gender             $ 1
		   loyalty_id         $ 7
           address_1          $ 60
           address_2          $ 60
           address_3          $ 60
           address_4          $ 20
           postcode           $ 8
           email1             $ 50
           contact_preference $ 6
           interests          $ 20;

	* Defining variables for import;
	input  customer_id
           family_name        $ 
           forename           $ 
           title              $ 
           gender             $ 
           dob                : date9.
           loyalty_id         $ 
           address_1          $ 
           address_2          $ 
           address_3          $ 
           address_4          $ 
           postcode           $ 
           email1             $ 
           contact_preference $
           interests          $ 
           customer_startdate : date9.
           contact_date       : date9.;
	
	* Adding labels to variables;
	label  customer_id        = 'Customer Identification'
		   postcode           = 'Postcode'
		   family_name        = 'Family Name'
		   forename           = 'Forename'
		   gender             = 'Gender'
		   title              = 'Title'
		   address_1          = 'Address1'
		   address_2          = 'Address2'
		   address_3          = 'Address3'
	 	   address_4          = 'Address4'
		   customer_startdate = 'Customer Enrolment Date'
		   contact_date       = 'Date Customer Last Contacted'
		   dob                = 'Date of Birth'
		   contact_preference = 'Customers Contact Preference'
		   loyalty_id         = 'Loyalty Identification'
		   interests          = 'Customer Interests'
		   email1             = 'Email Address';
	
	* Defining formats for variables;
	format dob                DDMMYY10.
	       customer_startdate DDMMYY10.
		   contact_date       DDMMYY10.;
run;

%* Testing dataset loaded successfully, else abort and give error;
%dsexist(custdata, households);

* Importing loyalty tabulated data;
data custdata.loyalty;
	* Import file to table;
	infile extdata(loyalty.dat) firstobs=2 DSD dlm='09'x;
	
	* Defining variable lengths for table;
	length loyalty_id    $ 7			
           investor_type $ 12;

	* Defining variables for import;
	input  account_id
           loyalty_id    $	
           invested_date : date9.	
           initial_value	
           investor_type $
           current_value;
	
	* Adding labels to variables;
	label  loyalty_id    = 'Loyalty Identification'
		   account_id    = 'Customer Account Number'
		   initial_value = 'Initial Share Value'
		   investor_type = 'Type of Investor'
		   current_value = 'Current Share Value'
		   invested_date = 'Investment Date';
	
	* Defining formats for variables;
	format invested_date DDMMYY10.;
run;

%* Testing dataset loaded successfully, else abort and give error;
%dsexist(custdata, loyalty);

/* Creating interest_coding dataset to theoretically allow code 
   to generalise to new interests and codes in future */
data custdata.interests;
	* Defining delimiter for datalines;
	infile cards delimiter=',';
	
	* Defining variable lengths for table - descriptions length 32 as they are used to generate variables, code length 7 to allow an expansion of 1 variable;
	length interest_code $ 7
	       description   $ 32;

	* Defining variables for import;
	input  interest_code $ 
           description   $;

	* Codes and interests - codes separated by | - interest after comma;
	datalines;
A|K|L,Mountaineering
B,Water Sports
C|X,Sightseeing
D,Cycling
E,Climbing
F|W,Dancing
H|G|J,Hiking
M,Snowboarding
N,White Water Rafting
P|Q|R,Scuba Diving
S,Yoga
T|U,Mountain Biking
V|Y|Z,Trail Walking
;
run;

%* Testing dataset loaded successfully, else abort and give error;
%dsexist(custdata, interests);

/* Producing a PDF of the Metadata for bookings, destinations, households, loyalty */
ods pdf file="&report_path.\ReportA-Metadata.pdf" style=Journal;
	* Change report orientation;
	option orientation=portrait;

	* Metadata Output for Bookings Dataset;
	%proccontents(custdata, bookings, title = Metadata for Holiday Bookings Dataset, outdat=custmeta.metadata_bookings);
	ods text='We have taken the maximum room name length to be 9 for dormitory. When defining the format the bookings dataset, we have assumed an upper-bound of £99,999.99 on holiday cost through intuition. It was necessary to informat all dates with date9, and skip a header on the first line contained in the csv file. Family_name is maximum length 25 to match the value chosen in households.';
	
	* Metadata Output for Destinations Dataset;
	%proccontents(custdata, destinations, title = Metadata for Holiday Destinations Dataset, outdat=custmeta.metadata_destinations);
	ods text='Title is length 4 to include lord/lady/king, we have assumed no Sheikhs and so on. We assumed destination descriptions have a maximum length 25, and skipped a header line in the CSV-file read-in.';
	
	* Metadata Output for Households Dataset;
	%proccontents(custdata, households, title = Metadata for Customer Details Dataset, outdat=custmeta.metadata_households);
	ods text='Family name was assumed a maximum length of 30 to allow for long/double-barrelled names. Forename was given maximum length 15 because only exceptional names would be that long without a nickname. We have chosen the maximum length of Address1 based on the longest street name in London, St Martin-in-the-Fields Church Path, which is 35 characters, 
plus 15 characters tolerance for "extras" like flat numbers and spaces. We make a similar assumptions for Address2 with 58 characters to accommodate the town Llanfairpwllgwyngyllgogerychwyrndrobwllllantysiliogogogoch. It was necessary to informat all dates with date9.';
	
	* Metadata Output for Loyalty Dataset;
	%proccontents(custdata, loyalty, title = Metadata for Loyalty Shares Dataset, outdat=custmeta.metadata_loyalty);
	ods text='It was necessary to informat all dates with date9. We assumed descriptions will be of maximum length 25.';

ods pdf close;
