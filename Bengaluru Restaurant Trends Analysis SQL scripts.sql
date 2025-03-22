use restaurant_blr;

/* ----------------------- check waht are the tables are in restaurant_blr database ---------------- */

show tables; -- Total 7 tables are there (cuisine, location, restaurant, ratings, restaurant_cuisine, restaurant_type, services)



/* --------------------- describe tables in restaurant_blr database ------------------------- */


describe cuisine; -- Valid data types and primary key is assigned for cuisine_id, need to check null values for cuisines column

describe location; -- Data types and primary key is assigned for location_id, need to check null values for location column

describe ratings; -- Data types is valid, assigned foreign key for restaurant_id, no primary key in this table, null values need to check for rate and votes columns.

describe restaurant; -- Valid data types, primary key assigned for restaurant_id, foreign key assigned for location_id and rest_type_id, need to check null for rest_name, address, phone, url, cost_for_two columns

describe restaurant_cuisine; -- valid data types, no null values allowed, foreign key assigned for both columns restaurant_id and cuisine_id, no primary key assigned, no need to check for null values. 

describe restaurant_type; -- Data types are valid, primary key assigned for rest_type_id, no foreign key assigned, need to check null values for rest_type column

describe services; -- Data types are valid, no primary key, foreign key assigned for restaurant_id, no need to check for null values because null values are not allowed in this table. 

/* Overall Insights:
For all tables data types and key assignment are valid, need some inspection about null values for few columns in few tables. */



/* ------------------- check for null values ------------------------------ */

/*1. Check null for cuisine column from cuisine table */

select count(*) tot_null from cuisine 
where cuisines is null; -- No null values in cuisines column

/*2. Check null for location column from location table */

select count(*) tot_null from location
where location is null; -- No null values in location column

/*3. Check null for rate and votes from ratings table */

select 
sum(case when rate is null then 1 else 0 end) rate_null,
sum(case when votes is null then 1 else 0 end) votes_null
from ratings; -- No null values for rate and votes columns

/*4. Check null values for rest_name, address, phone, url, cost_for_two columns from restaurant table */

select * from restaurant
where rest_name is null or
address is null or
phone is null or
url is null or 
cost_for_two is null; -- No null values in restaurant table

/*5. check null values for rest_type column from restaurant_type table */

select count(*) tot_null from restaurant_type
where rest_type is null; -- No null values in rest_type column



/* ------------------------- Exploratory Data analysis ------------------------ */

/* 1. Find Most Frequently Visited Restaurants */

select rest_name, count(*) rest_counts
from restaurant
group by rest_name
order by rest_counts desc
limit 10;

select * from ratings;

/* 2. Identify the restaurants do not accept online orders */

select re.rest_name, sv.online_order
from restaurant re left join services sv
on re.restaurant_id = sv.restaurant_id
where sv.online_order = 'No';

/* 3. Fetch online and offline restaurants precentage */

select online_order, count(*) order_cnt
from services
group by online_order;

/* 4. Identify the restaurants who provide online booking and not? */

select re.rest_name, sv.book_table
from restaurant re left join services sv
on re.restaurant_id = sv.restaurant_id;

/* 5. Check null values and convert values into numeric for rate column from ratings table */

/* SET SQL_SAFE_UPDATES = 0;

update ratings
set rate = '0.0'
where rate = '';

update ratings
set rate = '0.0'
where rate = '"NEW"';

update ratings
set rate = replace(rate, '/5', '');

update ratings
set rate = trim(both '"' from rate);

UPDATE ratings
SET rate = '0.0'
where rate = '-';

ALTER TABLE ratings
MODIFY COLUMN rate DECIMAL(3,1);

SET SQL_SAFE_UPDATES = 1; */


/* 6. Identify most rated cuisines in restaurants*/

select re.rest_name, cu.cuisines, ra.rate
from restaurant re left join ratings ra
on re.restaurant_id = ra.restaurant_id
left join restaurant_cuisine rc
on re.restaurant_id = rc.restaurant_id
left join cuisine cu 
on rc.cuisine_id = cu.cuisine_id;


/* 7. Find most common cuisines in each location */

with cuisine_location as (
select re.rest_name, lo.location, cu.cuisines
from location lo right join restaurant re 
on lo.location_id = re.location_id
left join restaurant_cuisine rc
on re.restaurant_id = rc.restaurant_id
left join cuisine cu 
on rc.cuisine_id = cu.cuisine_id
)
select cuisines, location, count(cuisines) cuisine_cnt 
from cuisine_location
group by cuisines, location;







