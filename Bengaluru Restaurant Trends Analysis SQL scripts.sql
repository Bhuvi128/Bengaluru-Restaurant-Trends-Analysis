/*
===============================================================================================================================================================================
===============================================================================================================================================================================
									-- Bengaluru Restaurant Trend Analysis --
===============================================================================================================================================================================
===============================================================================================================================================================================

*/


-- Problem Statement:
/* 
Bengaluru is a paradise for food lovers, offering over 12,000 restaurants with cuisines from all over the world. 
Despite the growing demand and daily openings of new restaurants, it remains challenging for newcomers to compete with 
well-established ones due to high costs, manpower issues, and stiff competition. This Zomato dataset helps analyze 
restaurant trends, customer preferences, and ratings across different neighborhoods in Bengaluru. 
It aims to guide new restaurants in choosing the right location, cuisine, pricing, and setup by understanding the 
factors that influence success in the city's diverse food scene.
*/

use restaurant_blr;

/*
==============================================================================================================================================================================
---------------------------------------------------------------------  Data Validation & Cleaning  ---------------------------------------------------------------------------
==============================================================================================================================================================================
*/

-- 1.1 Data Validation
describe cuisine;
describe location; 
describe ratings; 
describe restaurant; 
describe restaurant_cuisine; 
describe restaurant_type; 
describe services; 

-- 1.2 Data cleaning
SET SQL_SAFE_UPDATES = 0;

-- 1.2.1 clean ratings table 
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

-- 1.2.2 clean restaurant table

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


/*
==============================================================================================================================================================================
----------------------------------------------------------------------- Exploratory Data analysis ----------------------------------------------------------------------------
==============================================================================================================================================================================
*/

-- 2.1 Total number of restaurants in Bengaluru
select count(*) as total_restaurants 
from restaurant;

-- 2.2 Distribution of restaurant outlets
select rest_name, count(*) as total_outlets
from restaurant
group by rest_name
order by total_outlets desc;

-- 2.3 Distribution of restaurant outlets by restaurant category (listed_rest_type)
select li.listed_rest_type, count(distinct re.restaurant_id) total_outlets
from restaurant re left join listing_type li
on re.listing_id = li.listing_id
group by li.listed_rest_type
order by total_outlets desc;

-- 2.4 Distribution of restaurant outlets by cuisines
select cu.cuisines, count(distinct re.restaurant_id) total_outlets
from restaurant re left join restaurant_cuisine rc
on re.restaurant_id = rc.restaurant_id
left join cuisine cu
on rc.cuisine_id = cu.cuisine_id
group by cu.cuisines
order by total_outlets desc;

-- 2.5 Distribution of restaurant outlets by ratings
select ra.rate,
count(distinct re.restaurant_id) total_outlets
from restaurant re left join ratings ra
on re.restaurant_id = ra.restaurant_id
group by ra.rate
order by ra.rate, total_outlets desc;

-- 2.6 Distribution of restaurant outlets by votings
select ra.votes,
count(distinct re.restaurant_id) total_outlets
from restaurant re left join ratings ra
on re.restaurant_id = ra.restaurant_id
group by ra.votes
order by ra.votes, total_outlets desc;

-- 2.7 Distribution of restaurant outlets by locality
select lo.location, count(distinct re.restaurant_id) total_outlets
from location lo right join restaurant re 
on lo.location_id = re.location_id
group by lo.location
order by total_outlets desc;

-- 2.8 Online order distribution
select online_order, count(*) order_count
from services
group by online_order;

-- 2.9 Distribution of restaurant outlets by online order status
select sv.online_order, count(distinct re.restaurant_id) total_outlets
from services sv right join restaurant re
on sv.restaurant_id = re.restaurant_id
group by sv.online_order
order by total_outlets desc;

-- 2.10 Table booking distribution 
select book_table, count(*) booking_count
from services
group by book_table;

-- 2.11 Distribution of restaurant outlets by table booking status
select sv.book_table, count(distinct re.restaurant_id) total_outlets
from services sv right join restaurant re
on sv.restaurant_id = re.restaurant_id
group by sv.book_table
order by total_outlets desc;

-- 2.12 Distribution of restaurant outlets by restaurant type
select rt.rest_type, count(distinct re.restaurant_id) total_outlets
from restaurant re left join restaurant_type rt
on re.rest_type_id = rt.rest_type_id
group by rt.rest_type
order by total_outlets desc;

-- 2.13 Average cost for two and rating by locality
select lo.location, count(distinct re.restaurant_id) total_outlets,
round(avg(re.cost_for_two),2) avg_cost_for_two,
round(avg(ra.rate),2) avg_ratings
from restaurant re left join location lo
on re.location_id = lo.location_id
left join ratings ra
on re.restaurant_id = ra.restaurant_id
group by lo.location
order by lo.location;

-- 2.14 Top 3 restaurants per locality based on votes
with ranked_restaurants as (
	select 
	  re.rest_name,
      lo.location,
      ra.votes,
      rank() over(partition by lo.location order by ra.votes desc) as rank_in_location
    from restaurant re left join location lo
	on re.location_id = lo.location_id
	left join ratings ra
	on re.restaurant_id = ra.restaurant_id
)
select * from ranked_restaurants
where rank_in_location>= 3;

-- 2.15 Restaurants in top 10% ratings bracket
with percentile_rating as(
	select
      re.rest_name,
      ra.rate,
      percent_rank() over(order by ra.rate desc) as percentile_rank
	from ratings ra right join restaurant re 
    on ra.restaurant_id = re.restaurant_id
)
select * from percentile_rating;