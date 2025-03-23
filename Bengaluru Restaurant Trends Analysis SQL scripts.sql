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


/* ------------------------------ Data Cleaning ---------------------------------- */

/*
SET SQL_SAFE_UPDATES = 0;

-- clean ratings table 
select * from ratings;  
 
update ratings
set rate = '0.0'
where rate = '';

update ratings
set rate = '0.0'
where rate = '"NEW"';

update ratings
set rate = trim(both '"' from rate);

update ratings
set rate = replace(rate, '/5', '');

UPDATE ratings
SET rate = '0.0'
where rate = '-';

ALTER TABLE ratings
MODIFY COLUMN rate DECIMAL(3,1);

-- clean restaurant table

select * from restaurant;

update restaurant
set rest_name = trim(both '"' from rest_name);

update restaurant
set address = trim(both '"' from address);

update restaurant
set phone = trim(both '"' from phone);

update restaurant
set url = trim(both '"' from url);

SET SQL_SAFE_UPDATES = 1; 
*/



/* ------------------------- Exploratory Data analysis ------------------------ */

/* Find the top 10 Most Frequent Restaurant chains */

select rest_name, count(*) rest_counts
from restaurant
group by rest_name
order by rest_counts desc
limit 10;

/* Identify the top 12 most frequent restaurant chains and its category */

select re.rest_name, count(*) rest_counts,
group_concat(distinct li.listed_rest_type) as restaurant_category
from restaurant re left join listing_type li
on re.listing_id = li.listing_id
group by re.rest_name
order by rest_counts desc
limit 12;

/* Find the most common restaurant category the restaurant chains providing */

select li.listed_rest_type, count(distinct re.restaurant_id) rest_counts
from restaurant re left join listing_type li
on re.listing_id = li.listing_id
group by li.listed_rest_type
order by rest_counts desc;

/* Identify the top 15 most frequently occurring cuisines in restaurants */

select re.rest_name, count(distinct re.restaurant_id) rest_counts,
group_concat(distinct cu.cuisines) as cuisine_rest
from restaurant re left join restaurant_cuisine rc
on re.restaurant_id = rc.restaurant_id
left join cuisine cu
on rc.cuisine_id = cu.cuisine_id
group by re.rest_name
order by rest_counts desc
limit 15;

/* Find most common cuisines, restaurants providing */

select cu.cuisines, count(distinct re.restaurant_id) rest_counts
from restaurant re left join restaurant_cuisine rc
on re.restaurant_id = rc.restaurant_id
left join cuisine cu
on rc.cuisine_id = cu.cuisine_id
group by cu.cuisines
order by rest_counts desc
limit 15;

/* Fetch cost_for_two from restaurant table to calculate summary statistics */

select cost_for_two from restaurant;

/* Identify top 15 restaurant chains and thier cost for two */

select rest_name, count(distinct restaurant_id) total_outlets,
round(avg(cost_for_two),2) avg_cost_for_two
from restaurant 
group by rest_name
order by total_outlets desc
limit 15;

/* Identify the top 15 most frequently occurring locations the restaurant chains have */

select lo.location, count(distinct re.restaurant_id) total_outlets
from location lo right join restaurant re 
on lo.location_id = re.location_id
group by lo.location
order by total_outlets desc
limit 15;

/* Find the top 15 most frequent restaurant chains along with their ratings and votes */

select re.rest_name, count(distinct re.restaurant_id) total_outlets,
round(avg(ra.rate),2) avg_ratings, sum(ra.votes) total_votings
from ratings ra right join restaurant re 
on ra.restaurant_id = re.restaurant_id
group by re.rest_name
order by avg_ratings desc
limit 15;

/* List out restaurants have ratings with 4 or more */

select re.rest_name, count(distinct re.restaurant_id) total_outlets,
round(avg(ra.rate),2) avg_ratings, sum(ra.votes) total_votings
from ratings ra right join restaurant re 
on ra.restaurant_id = re.restaurant_id
group by re.rest_name
having avg_ratings >= 4.0
order by avg_ratings desc
limit 15;

/* Identify which category the restaurants having rating 4 or more */

select re.rest_name, 
group_concat(distinct li.listed_rest_type) restaurant_category,
count(distinct re.restaurant_id) total_outlets,
round(avg(ra.rate),2) avg_ratings, sum(ra.votes) total_votings
from ratings ra right join restaurant re 
on ra.restaurant_id = re.restaurant_id
left join listing_type li
on re.listing_id = li.listing_id
group by re.rest_name
having avg_ratings >= 4.0
order by avg_ratings desc
limit 15;

/* Identify the restaurants having rating 4 and above with their cuisines */

create view rest_cuisines_rating_4 as
select re.rest_name, 
group_concat(distinct cu.cuisines) rest_cuisines,
count(distinct re.restaurant_id) total_outlets,
round(avg(ra.rate),2) avg_ratings, sum(ra.votes) total_votings
from ratings ra right join restaurant re 
on ra.restaurant_id = re.restaurant_id
left join restaurant_cuisine rc 
on re.restaurant_id = rc.restaurant_id
left join cuisine cu
on rc.cuisine_id = cu.cuisine_id
group by re.rest_name
having avg_ratings >= 4.0
order by avg_ratings desc
limit 15;

/* Identify restaurants with rating 4 and above and thier cost for two */

select re.rest_name, count(distinct re.restaurant_id) total_outlets,
round(avg(ra.rate),2) avg_ratings, sum(ra.votes) total_votings,
round(avg(re.cost_for_two),2) avg_cost_for_two
from restaurant re inner join ratings ra
on re.restaurant_id = ra.restaurant_id
group by rest_name
having avg_ratings >= 4.0
order by avg_ratings desc
limit 15;

/* Identify the restaurants do not accept online orders */

select re.rest_name, sv.online_order
from restaurant re left join services sv
on re.restaurant_id = sv.restaurant_id
where sv.online_order = 'No';



/* Fetch online and offline restaurants precentage */

select online_order, count(*) order_cnt
from services
group by online_order;

/* Identify the restaurants who provide online booking and not? */

select re.rest_name, sv.book_table
from restaurant re left join services sv
on re.restaurant_id = sv.restaurant_id;

/* Identify most rated cuisines in restaurants*/

select re.rest_name, cu.cuisines, ra.rate
from restaurant re left join ratings ra
on re.restaurant_id = ra.restaurant_id
left join restaurant_cuisine rc
on re.restaurant_id = rc.restaurant_id
left join cuisine cu 
on rc.cuisine_id = cu.cuisine_id;


/* Find most common cuisines in each location */

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







