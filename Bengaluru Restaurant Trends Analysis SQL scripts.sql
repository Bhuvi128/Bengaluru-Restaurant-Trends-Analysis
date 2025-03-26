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

UPDATE services 
SET book_table = TRIM(book_table);

UPDATE services 
SET book_table = REPLACE(book_table, CHAR(13), '');

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

/* Find the top 15 most frequent restaurant chains along with their ratings and votes */

select re.rest_name, count(distinct re.restaurant_id) total_outlets,
round(avg(ra.rate),2) avg_ratings, sum(ra.votes) total_votings
from ratings ra right join restaurant re 
on ra.restaurant_id = re.restaurant_id
group by re.rest_name
order by total_outlets desc
limit 15;

/* Check relationship between average ratings and total votings */

select rate, count(*) rest_counts, round(avg(votes),2) avg_votes 
from ratings
group by rate
order by rate desc;

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

/* Find the top 15 restaurant chains with thier restaurant type */

select re.rest_name, count(distinct re.restaurant_id) total_outlets,
group_concat(distinct rt.rest_type) rest_type
from restaurant re left join restaurant_type rt
on re.rest_type_id = rt.rest_type_id
group by re.rest_name
order by total_outlets desc
limit 15;

/* Identify the top 15 restaurant chains who providing and not providing online orders */

select re.rest_name,
count(distinct case when sv.online_order = 'Yes' then re.restaurant_id end) provide_online_order,
count(distinct case when sv.online_order = 'No' then re.restaurant_id end) does_not_provide_online_order
from restaurant re left join services sv
on re.restaurant_id = sv.restaurant_id
group by re.rest_name
order by (provide_online_order + does_not_provide_online_order) desc
limit 15;

/* Identify top 15 restaurant chains who providing and not providing table booking */

select re.rest_name,
count(distinct case when sv.book_table = 'Yes' then re.restaurant_id end) provide_table_booking,
count(distinct case when sv.book_table = 'No' then re.restaurant_id end) does_not_provide_table_booking
from restaurant re left join services sv
on re.restaurant_id = sv.restaurant_id
group by re.rest_name
order by (provide_table_booking + does_not_provide_table_booking) desc
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

/* Identify restaurant chains having 4 and above rating with thier restaurant type */

select re.rest_name, count(distinct re.restaurant_id) total_outlets,
group_concat(distinct rt.rest_type) rest_type,
round(avg(ra.rate),2) avg_ratings, sum(ra.votes) total_votings
from restaurant re left join restaurant_type rt
on re.rest_type_id = rt.rest_type_id
left join ratings ra
on re.restaurant_id = ra.restaurant_id
group by re.rest_name
having avg_ratings >= 4.0
order by avg_ratings desc
limit 15;

/* List out the restaurant chains with rating 4 and above with online order status */

select re.rest_name,
count(distinct case when sv.online_order = 'Yes' then re.restaurant_id end) online_order,
count(distinct case when sv.online_order = 'No' then re.restaurant_id end) offline_order,
round(avg(ra.rate),2) avg_ratings, sum(ra.votes) total_votings
from restaurant re left join ratings ra
on re.restaurant_id = ra.restaurant_id
left join services sv
on re.restaurant_id = sv.restaurant_id
group by re.rest_name
having avg_ratings >= 4.0
order by avg_ratings desc
limit 15;

/* List out restaurant chains with rating 4 and above with table booking status */

select re.rest_name,
count(distinct case when sv.book_table = 'Yes' then re.restaurant_id end) providing_table_booking,
count(distinct case when sv.book_table = 'No' then re.restaurant_id end) does_not_providing_table_booking,
round(avg(ra.rate),2) avg_ratings, sum(ra.votes) total_votings
from restaurant re left join ratings ra
on re.restaurant_id = ra.restaurant_id
left join services sv
on re.restaurant_id = sv.restaurant_id
group by re.rest_name
having avg_ratings >= 4.0
order by avg_ratings desc
limit 15;

/* Fetch online and offline restaurants precentage */

select online_order, count(*) order_cnt
from services
group by online_order;

/* Identify the restaurants who provide online booking and not? */

select re.rest_name, sv.book_table
from restaurant re left join services sv
on re.restaurant_id = sv.restaurant_id;

/* Identify top most restaurant types */

select rt.rest_type, count(distinct re.restaurant_id) total_outlets
from restaurant re left join restaurant_type rt
on re.rest_type_id = rt.rest_type_id
group by rt.rest_type
order by total_outlets desc
limit 15;

/* Identify what are the cuisines there for top most restaurant types */

select rt.rest_type, cu.cuisines,
count(distinct re.restaurant_id) total_outlets
from restaurant re left join restaurant_type rt
on re.rest_type_id = rt.rest_type_id
left join restaurant_cuisine rc
on re.restaurant_id = rc.restaurant_id
left join cuisine cu
on rc.cuisine_id = cu.cuisine_id
group by rt.rest_type, cu.cuisines
order by total_outlets desc
limit 15;

/* Identify the top most restaurant types and their average ratings and total votings */

select rt.rest_type, count(distinct re.restaurant_id) total_outlets,
round(avg(ra.rate),2) avg_ratings, sum(ra.votes) total_votings
from ratings ra right join restaurant re 
on ra.restaurant_id = re.restaurant_id
left join restaurant_type rt
on re.rest_type_id = rt.rest_type_id
group by rt.rest_type
order by total_outlets desc
limit 15;

/* Identify the top most restaurant types and their average cost for two */

select rt.rest_type, count(distinct re.restaurant_id) total_outlets,
round(avg(re.cost_for_two),2) avg_cost_two
from restaurant_type rt right join restaurant re
on rt.rest_type_id = re.rest_type_id
group by rt.rest_type
order by total_outlets desc
limit 15;

/* Find whcih restaurant types providing and not providing online order */

select rt.rest_type,
count(distinct case when sv.online_order = 'Yes' then re.restaurant_id end) provide_online_order,
count(distinct case when sv.online_order = 'No' then re.restaurant_id end) does_not_provide_online_order
from restaurant re left join services sv
on re.restaurant_id = sv.restaurant_id
left join restaurant_type rt
on re.rest_type_id = rt.rest_type_id
group by rt.rest_type
order by (provide_online_order + does_not_provide_online_order) desc
limit 15;

/* Find which restaurant types providing and not providing table booking */

select rt.rest_type,
count(distinct case when sv.book_table = 'Yes' then re.restaurant_id end) provide_table_booking,
count(distinct case when sv.book_table = 'No' then re.restaurant_id end) does_not_provide_table_booking
from restaurant re left join services sv
on re.restaurant_id = sv.restaurant_id
left join restaurant_type rt
on re.rest_type_id = rt.rest_type_id
group by rt.rest_type
order by (provide_table_booking + does_not_provide_table_booking) desc
limit 15;

/* Identify the top most restaurant types and thier city location */

select rt.rest_type, lc.listed_city,
count(distinct re.restaurant_id) total_outlets
from restaurant_type rt right join restaurant re
on rt.rest_type_id = re.rest_type_id
left join listing_city lc
on re.listing_city_id = lc.listing_city_id
group by rt.rest_type, lc.listed_city
order by total_outlets desc
limit 30;

/* Find the top most city, the restaurant chains have */

select lc.listed_city, count(distinct re.restaurant_id) total_outlets
from restaurant re left join listing_city lc
on re.listing_city_id = lc.listing_city_id
group by lc.listed_city
order by total_outlets desc
limit 15;

/* Identify the top most city and thier restaurant category */

select lc.listed_city, li.listed_rest_type,
count(distinct re.restaurant_id) total_outlets
from listing_city lc right join restaurant re
on lc.listing_city_id = re.listing_city_id
left join listing_type li
on re.listing_id = li.listing_id
group by lc.listed_city, li.listed_rest_type
order by total_outlets desc
limit 15;

/* Identify the top most restaurant city with thier ratings */

select lc.listed_city, count(distinct re.restaurant_id) total_outlets,
round(avg(ra.rate),2) avg_ratings, sum(ra.votes) total_votings
from listing_city lc right join restaurant re 
on lc.listing_city_id = re.listing_city_id
left join ratings ra
on re.restaurant_id = ra.restaurant_id
group by lc.listed_city
order by total_outlets desc
limit 15;

/* Identify the top most restaurant city with their average cost for two */

select lc.listed_city, count(distinct re.restaurant_id) total_outlets,
round(avg(re.cost_for_two),2) avg_cost_two
from listing_city lc right join restaurant re
on lc.listing_city_id = re.listing_city_id
group by lc.listed_city
order by total_outlets desc
limit 15;

/* Identify the top most restaurant with thier cuisines */

select lc.listed_city, cu.cuisines,
count(distinct re.restaurant_id) total_outlets
from restaurant re left join listing_city lc
on re.listing_city_id = lc.listing_city_id
left join restaurant_cuisine rc
on re.restaurant_id = rc.restaurant_id
left join cuisine cu
on rc.cuisine_id = cu.cuisine_id
group by lc.listed_city, cu.cuisines
order by total_outlets desc
limit 30;

/* Find the restaurant city providing and not providing online order */

select lc.listed_city, sv.online_order,
count(distinct re.restaurant_id) total_outlets
from services sv right join restaurant re 
on sv.restaurant_id = re.restaurant_id
left join listing_city lc
on re.listing_city_id = lc.listing_city_id
group by lc.listed_city, sv.online_order
order by total_outlets desc
limit 30;

/* Identify the restaurant city providing and not providing table booking */

select lc.listed_city, sv.book_table,
count(distinct re.restaurant_id) total_outlets
from services sv right join restaurant re 
on sv.restaurant_id = re.restaurant_id
left join listing_city lc
on re.listing_city_id = lc.listing_city_id
group by lc.listed_city, sv.book_table
order by total_outlets desc
limit 30;









