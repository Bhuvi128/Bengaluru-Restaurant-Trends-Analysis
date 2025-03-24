-- create database restaurant_blr;

-- use restaurant_blr;

/*
create table location (
location_id	int unsigned not null,
location text,
primary key (location_id)
);

create table listing_type (
listing_id int unsigned not null,
listed_rest_type varchar(255),
primary key (listing_id)
);

create table listing_city (
listing_city_id	int unsigned not null,
listed_city varchar(300),
primary key (listing_city_id)
);

create table restaurant_type (
rest_type_id int unsigned not null,	
rest_type text,
primary key (rest_type_id)
);

create table cuisine (
cuisine_id int unsigned not null,
cuisines text,
primary key (cuisine_id)
);


create table restaurant (
restaurant_id int unsigned not null,	
location_id	int unsigned not null,
rest_type_id int unsigned not null,
listing_id int unsigned not null,
listing_city_id int unsigned not null,
rest_name text,
address	text,
phone varchar(300) default null,
url	text,
cost_for_two int default null,
primary key (restaurant_id),
foreign key (location_id) references location(location_id),
foreign key (rest_type_id) references restaurant_type(rest_type_id),
foreign key (listing_id) references listing_type(listing_id),
foreign key (listing_city_id) references listing_city(listing_city_id)
);

create table restaurant_cuisine (
restaurant_id int unsigned not null,
cuisine_id int unsigned not null,
foreign key (restaurant_id) references restaurant(restaurant_id),
foreign key (cuisine_id) references cuisine(cuisine_id)
);

create table services (
restaurant_id int unsigned not null,
online_order varchar(100) not null,	
book_table varchar(100) not null,
foreign key (restaurant_id) references restaurant(restaurant_id)
);

create table ratings (
restaurant_id int unsigned not null,
rate varchar(255) default null,
votes int default null,
foreign key (restaurant_id) references restaurant(restaurant_id)
);

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/location.csv"
into table location
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from location;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/listing_type.csv"
into table listing_type
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from listing_type;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/listing_city.csv"
into table listing_city
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from listing_city;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/rest_type.csv"
into table restaurant_type
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from restaurant_type;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/cuisine.csv"
into table cuisine
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;

select * from cuisine;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/restaurant.csv"
into table restaurant
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 rows;

select * from restaurant;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/restaurant_cuisine.csv"
into table restaurant_cuisine
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 rows;

select * from restaurant_cuisine;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/services.csv"
into table services
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 rows;

select * from services;

load data infile "C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/rating.csv"
into table ratings
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 rows;

select * from ratings;
*/
