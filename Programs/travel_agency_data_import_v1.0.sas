************************************************************************
* Name: travel_agency_data_import.sas                                  *
* Description: Travel Agency Project Data Import                       *
* Creation Date: 06/04/2023                                            *
* Created by: James Wright                                             *
*             Graduate Programmer                                      *
*             Katalyze Data Ltd.                                       *
************************************************************************;

/* Defining data input files and locations */
* Path to original datasets;
%let data_path = &project_path.\SAS\Data\Inputs;
* Assigning path variable pointer;
filename extdata "&data_path.";

/* Definine SAS data files, libraries, and locations */
*Path to point library to;
%let lib_path = &project_path.\SAS\Data;
* Assigning custdata library for raw data;
libname custdata "&lib_path.\Raw";
* Assigning staging data library for cleaning data in;
libname custstag "&lib_path.\Staging";
* Assigning detail data library for cleaned data;
libname custdetl "&lib_path.\Detail";
* Assigning marts data library for data subsets;
libname custmart "&lib_path.\Marts";
* Assigning exceptions data library for exceptional values;
libname custexcp "&lib_path.\Exceptions";
* Assigning metadata data library for metadata;
libname custmeta "&lib_path.\Metadata";

/* Importing data to SAS datasets */
* Importing bookings csv data;
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

* Importing destinations csv data;
data custdata.destinations;
	infile extdata(destinations.csv) firstobs=2 DSD;

	length destination_code $ 2
	       description $ 25;

	input  destination_code $
           description $;

	label  destination_code = 'Destination Code'
		   description = 'Description';
run;

* Importing households csv data;
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

* Importing loyalty tabulated data;
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
ods pdf file="&report_dest.\ReportA.pdf";

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
	
	* Metadata Output for Bookings Dataset;
	%proccontents(custdata, loyalty, title = Metadata for Loyalty Shares Dataset);
	ods text='It was necessary to informat all dates with date9. We assumed descriptions will be of maximum length 25.';

ods pdf close;
