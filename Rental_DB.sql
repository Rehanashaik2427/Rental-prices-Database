DROP DATABASE IF EXISTS `Rental_DB`;
CREATE DATABASE Rental_Db;
USE Rental_Db;
-- Create `vehicles` table
DROP TABLE IF EXISTS `vehicles`;
/**
	-- Enumeration of one of the items in the list(`category` ENUM('car', 'truck') NOT NULL DEFAULT 'car'),
    -- desc is a keyword (for descending) and must be back-quoted (`desc` VARCHAR(256) NOT NULL DEFAULT ''),
     -- binary large object of up to 64KB -- to be implemented later
     -- set default to max value (`daily_rate` DECIMAL(6,2) NOT NULL DEFAULT 9999.99)
     -- Build index on this column for fast search(INDEX (`category`) )
**/
CREATE TABLE `vehicles` (
`veh_reg_no` VARCHAR(8) NOT NULL,`category` ENUM('car', 'truck') NOT NULL DEFAULT 'car',
`brand` VARCHAR(30) NOT NULL DEFAULT '',`desc` VARCHAR(256) NOT NULL DEFAULT '',
`photo` BLOB NULL,`daily_rate` DECIMAL(6,2) NOT NULL DEFAULT 9999.99,
PRIMARY KEY (`veh_reg_no`),INDEX (`category`) 
);
DESC `vehicles`;
SHOW CREATE TABLE `vehicles`; 
SHOW INDEX FROM `vehicles` ;

-- Inserting test records in vehicles table
INSERT INTO `vehicles` VALUES
('SBA1111A', 'car', 'NISSAN SUNNY 1.6L', '4 Door Saloon, Automatic', NULL, 99.99),
('SBB2222B', 'car', 'TOYOTA ALTIS 1.6L', '4 Door Saloon, Automatic', NULL, 99.99),
('SBC3333C', 'car', 'HONDA CIVIC 1.8L', '4 Door Saloon, Automatic', NULL, 119.99),
('GA5555E', 'truck', 'NISSAN CABSTAR 3.0L', 'Lorry, Manual ', NULL, 89.99),
('GA6666F', 'truck', 'OPEL COMBO 1.6L', 'Van, Manual', NULL, 69.99);

-- No photo yet, set to NULL
SELECT * FROM `vehicles`;
-- Create `customers` table
DROP TABLE IF EXISTS `customers`;
/**
	-- Always use INT for AUTO_INCREMENT column to avoid run-over `customer_id` INT UNSIGNED NOT NULL AUTO_INCREMENT
    -- Build index on this unique-value column UNIQUE INDEX (`phone`)
    -- Build index on this column INDEX (`name`)
    **/
CREATE TABLE `customers` (
`customer_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,`name` VARCHAR(30) NOT NULL DEFAULT '',
`address` VARCHAR(80) NOT NULL DEFAULT '',`phone` VARCHAR(15) NOT NULL DEFAULT '',
`discount` DOUBLE NOT NULL DEFAULT 0.0,PRIMARY KEY (`customer_id`),
UNIQUE INDEX (`phone`), INDEX (`name`) 
);
DESC `customers`;
SHOW CREATE TABLE `customers`; 
SHOW INDEX FROM `customers`;
-- Inserting test records in CUSTOMERS  table
INSERT INTO `customers` VALUES
(1001, 'Tan Ah Teck', '8 Happy Ave', '88888888', 0.1),
(NULL, 'Mohammed Ali', '1 Kg Java', '99999999', 0.15),
(NULL, 'Kumar', '5 Serangoon Road', '55555555', 0),
(NULL, 'Kevin Jones', '2 Sunset boulevard', '22222222', 0.2);

SELECT * FROM `customers`;

-- Create `rental_records` table
/**
	-- Keep the created and last updated timestamp for auditing and security 
    (`lastUpdated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP),
	-- Disallow deletion of parent record if there are matching records here
	-- If parent record (customer_id) changes, update the matching records here
    (FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`) ON DELETE RESTRICT ON UPDATE CASCADE)
    **/
DROP TABLE IF EXISTS `rental_records`;
CREATE TABLE `rental_records` (
`rental_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,`veh_reg_no` VARCHAR(8) NOT NULL,`customer_id` INT UNSIGNED NOT NULL,
`start_date` DATE NOT NULL DEFAULT '2023-08-11',`end_date` DATE NOT NULL DEFAULT '2023-08-11',
`lastUpdated` TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,PRIMARY KEY (`rental_id`),
FOREIGN KEY (`customer_id`) REFERENCES `customers` (`customer_id`)ON DELETE RESTRICT ON UPDATE CASCADE,
FOREIGN KEY (`veh_reg_no`) REFERENCES `vehicles` (`veh_reg_no`)ON DELETE RESTRICT ON UPDATE CASCADE
) ;
DESC `rental_records`;
SHOW CREATE TABLE `rental_records`;
SHOW INDEX FROM `rental_records` ;

-- Inserting test records in RENTAL_RECORDS table

INSERT INTO `rental_records` VALUES
(NULL, 'SBA1111A', 1001, '2012-01-01', '2012-01-21', '2012-01-21'),
(NULL, 'SBA1111A', 1001, '2012-02-01', '2012-02-05', '2012-02-05'),
(NULL, 'GA5555E', 1003, '2012-01-05', '2012-01-31', '2012-01-31'),
(NULL, 'GA6666F', 1004, '2012-01-20', '2012-02-20', '2012-02-20');

SELECT * FROM `rental_records`;
truncate table `rental_records`;

/**
	Customer 'Tan Ah Teck' has rented 'SBA1111A' from today for 10 days. (Hint: You need to insert a rental record. Use a
SELECT subquery to get the customer_id. Use CURDATE() (or NOW()) for today; and DATE_ADD(CURDATE(), INTERVAL x
unit) to compute a future date.)
	CURDATE()->CURRENTDATE
	**/

INSERT INTO rental_records(rental_id, veh_reg_no,customer_id,start_date,end_date) VALUES
(NULL,
'SBA1111A',
(SELECT customer_id FROM customers WHERE name='Tan Ah Teck'),
CURDATE(),
DATE_ADD(CURDATE(), INTERVAL 10 DAY));

INSERT INTO rental_records(rental_id, veh_reg_no,customer_id,start_date,end_date) VALUES
(NULL,
'SBA1111A',
(SELECT customer_id FROM customers WHERE name='Kumar'),
CURDATE()+1,
DATE_ADD(CURDATE(), INTERVAL 90 DAY));

/** List all rental records (start date, end date) with vehicle's registration number, brand, and customer name, sorted by vehicle's**/

SELECT r.start_date AS `Start_Date`,r.end_date AS `End_Date`,r.veh_reg_no AS `Vehicle_No`,
v.brand AS `Vehicle_Brand`,c.name AS `Customer_Name`FROM rental_records AS r
INNER JOIN vehicles AS v USING (veh_reg_no)INNER JOIN customers AS c USING (customer_id)
ORDER BY v.category, r.start_date;
 
 
 -- List all the expired rental records (end_date before CURDATE()).
 
SELECT * FROM rental_records WHERE end_date<CURDATE();

-- 
/**
List the vehicles rented out on '2012-01-10' (not available for rental), in columns of vehicle registration no, customer name,
start date and end date. (Hint: the given date is in between the start_date and end_date.)
**/

SELECT v.veh_reg_no AS 'vehicle registration no',c.name AS 'CUSTOMER NAME',
r.start_date AS 'START DATE',r.end_date AS 'END DATE' 
FROM RENTAL_RECORDS r JOIN CUSTOMERS c ON  r.customer_id=c.customer_id JOIN VEHICLES v ON r.veh_reg_no=v.veh_reg_no 
WHERE '2012-01-10' BETWEEN  r.start_date AND r.end_date;

SELECT v.veh_reg_no AS 'vehicle registration no',c.name AS 'CUSTOMER NAME',
r.start_date AS 'START DATE',r.end_date AS 'END DATE' 
FROM RENTAL_RECORDS r JOIN CUSTOMERS c ON  r.customer_id=c.customer_id JOIN VEHICLES v ON r.veh_reg_no=v.veh_reg_no 
WHERE  r.start_date<='2012-01-10' AND r.end_date>'2012-01-10';





SELECT *FROM VEHICLES;
SELECT * FROM CUSTOMERS;
SELECT * FROM RENTAL_RECORDS;

-- . List all vehicles rented out today, in columns registration number, customer name, start date, end date.

SELECT v.veh_reg_no AS 'vehicle registration no',c.name AS 'CUSTOMER NAME',
r.start_date AS 'START DATE',r.end_date AS 'END DATE' 
FROM RENTAL_RECORDS r JOIN CUSTOMERS c ON  r.customer_id=c.customer_id JOIN VEHICLES v ON r.veh_reg_no=v.veh_reg_no 
WHERE DATE(R.START_DATE)<=CURDATE() AND DATE(R.END_DATE)>=CURDATE();

/**
	Similarly, list the vehicles rented out (not available for rental) for the period from '2012-01-03' to '2012-01-18'. (Hint:
start_date is inside the range; or end_date is inside the range; or start_date is before the range and end_date is beyond
the range.)
**/
SELECT v.veh_reg_no AS 'vehicle registration no',c.name AS 'CUSTOMER NAME',
r.start_date AS 'START DATE',r.end_date AS 'END DATE' 
FROM RENTAL_RECORDS r JOIN CUSTOMERS c ON  r.customer_id=c.customer_id JOIN VEHICLES v ON r.veh_reg_no=v.veh_reg_no 
WHERE ('2012-01-03'  BETWEEN R.START_DATE AND R.END_DATE ) OR   ('2012-01-18'  BETWEEN R.START_DATE AND R.END_DATE) OR
R.START_DATE<'2012-01-03' AND R.END_DATE>'2012-01-18' ;

-- .
/** List the vehicles (registration number, brand and description) available for rental (not rented out) on '2012-01-10' (Hint: You
could use a subquery based on a earlier query).
**/

SELECT v.veh_reg_no AS 'Registration number' ,v.brand AS 'Brand',v.desc AS 'description' FROM vehicles  v WHERE  v.veh_reg_no NOT IN
(SELECT r.veh_reg_no FROM rental_records r WHERE '2012-01-10' BETWEEN r.start_date AND r.end_date); 

-- Similarly, list the vehicles available for rental for the period from '2012-01-03' to '2012-01-18'.
 SELECT v.veh_reg_no AS 'Registration number' ,v.brand AS 'Brand',v.desc AS 'description' FROM vehicles  v WHERE  v.veh_reg_no NOT IN
(SELECT r.veh_reg_no FROM rental_records r 
	WHERE ('2012-01-13' BETWEEN r.start_date AND r.end_date) or
	('2012-01-18' BETWEEN r.start_date AND r.end_date) or  
    (r.start_date<'2012-01-03' AND r.end_date>'2012-01-18')
);



-- Similarly, list the vehicles available for rental from today for 10 days.

 SELECT v.veh_reg_no AS 'Registration number' ,v.brand AS 'Brand',v.desc AS 'description' FROM vehicles  v WHERE  v.veh_reg_no NOT IN
(SELECT r.veh_reg_no FROM rental_records r 
	WHERE (CURDATE() BETWEEN r.start_date AND r.end_date) or
	(DATE_ADD(CURDATE(),INTERVAL 10 DAY) BETWEEN r.start_date AND r.end_date) or  
    (r.start_date<CURDATE() AND r.end_date>CURDATE())
);


-- Try updating a parent row with matching row(s) in child table(s), e.g., rename 'GA6666F' to 'GA9999F' in vehicles table.
UPDATE vehicles set veh_reg_no='GA9999F' where veh_reg_no='GA6666F';
-- . Try deleting a parent row with matching row(s) in child table(s), e.g., delete 'GA9999F' from vehicles table (ON DELETE RESTRICT).

delete from vehicles where veh_reg_no='GA9999F';# we cannot delete bcz vehicles and rental records has parent child relationship

-- Remove 'GA6666F' from the database (Hints: Remove it from child table rental_records; then parent table vehicles.)
delete from rental_records where veh_reg_no='GA9999F';# first delete the row in child
delete from vehicles where veh_reg_no='GA9999F';# and then delete from parent



-- 
/** 
	Payments: A rental could be paid over a number of payments (e.g., deposit, installments, full payment). Each payment is for one
rental. Create a new table called payments. Need to create columns to facilitate proper audit check (such as create_date,
create_by, last_update_date, last_update_by, etc.)
**/

DROP TABLE IF EXISTS `payments`;
CREATE TABLE payments
(
	`payment_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,`rental_id` INT UNSIGNED NOT NULL,
	`amount` DECIMAL(8,2) NOT NULL DEFAULT 0,`mode` ENUM('cash', 'credit card', 'check'),
	`type` ENUM('deposit', 'partial', 'full') NOT NULL DEFAULT 'full',`remark` VARCHAR(255),
	`created_date` DATETIME NOT NULL,`created_by` INT UNSIGNED NOT NULL, -- staff_id
	-- Use a trigger to update create_date and create_by automatically
	`last_updated_date` TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP, -- Updated by the system automatically
	`last_updated_by` INT UNSIGNED NOT NULL, -- Use a trigger to update created_by
	PRIMARY KEY (`payment_id`),INDEX (`rental_id`),
	FOREIGN KEY (`rental_id`) REFERENCES rental_records (`rental_id`)
);
DESC `payments`;
/**
	This command will provide you with the complete SQL statement used to create the payments table, 
    including column definitions, data types, constraints, and indexes.
    **/
SHOW CREATE TABLE `payments` ;
-- 
/** 
This command will provide information about the indexes defined on the payments table,
 including their names, columns, uniqueness, and other relevant details.
**/
SHOW INDEX FROM `payments`;

-- table staff
/**
. Staff: Keeping track of staff serving the customers. Create a new staff table. Assume that each transaction is handled by one
staff, we can add a new column called staff_id in the rental_records table,
**/
DROP TABLE IF EXISTS `staff`;

CREATE TABLE `staff` (
`staff_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,-- Always use INT for AUTO_INCREMENT column to prvent run-over
`name` VARCHAR(30) NOT NULL DEFAULT '',`title` VARCHAR(30) NOT NULL DEFAULT '',
`address` VARCHAR(80) NOT NULL DEFAULT '',`phone` VARCHAR(15) NOT NULL DEFAULT '',
`report_to` INT UNSIGNED NOT NULL,-- Reports to manager staff_id. Boss reports to himself
 PRIMARY KEY (`staff_id`),UNIQUE INDEX (`phone`), -- Build index on this unique-value column
INDEX (`name`), -- Build index on this column
FOREIGN KEY (`report_to`) REFERENCES `staff` (`staff_id`)-- Reference itself
) ;
DESC `staff`;
SHOW INDEX FROM `staff` ;

-- insert values into staff table
INSERT INTO staff VALUE (8001, 'Peter Johns', 'Managing Director', '1 Happy Ave', '12345678', 8001);
SELECT * FROM staff;
-- aletr table  rental records add the column staff id
 ALTER TABLE `rental_records` ADD COLUMN `staff_id` INT UNSIGNED NOT NULL;
-- UPDATE the staff id  in rental records
UPDATE `rental_records` SET `staff_id` =8001;
SELECT * FROM  rental_records;
-- adding the foreign key
ALTER TABLE `rental_records` ADD FOREIGN KEY (`staff_id`) REFERENCES staff (`staff_id`) ON DELETE RESTRICT ON UPDATE CASCADE;

-- add the new column to the payments table
ALTER TABLE `payments` ADD COLUMN `staff_id` INT UNSIGNED NOT NULL;
SELECT * FROM payments;
-- UPDATE the staff id  in payments
UPDATE `payments` SET `staff_id` =8001;
ALTER TABLE `payments` ADD FOREIGN KEY (`staff_id`) REFERENCES staff (`staff_id`)
ON DELETE RESTRICT ON UPDATE CASCADE;

SHOW CREATE TABLE `payments` ;
SHOW INDEX FROM `payments` ;


DROP VIEW IF EXISTS rental_prices;
CREATE VIEW rental_prices
AS
SELECT
v.veh_reg_no AS `Vehicle No`,
v.daily_rate AS `Daily Rate`,
c.name AS `Customer Name`,
c.discount*100 AS `Customer Discount (%)`,
r.start_date AS `Start Date`,
r.end_date AS `End Date`,
DATEDIFF(r.end_date, r.start_date) AS `Duration`,
-- Compute the rental price
-- Preferred customer has discount, 20% discount for 7 or more days
-- CAST the result from DOUBLE to DECIMAL(8,2)
CAST(
IF (DATEDIFF(r.end_date, r.start_date) < 7,
DATEDIFF(r.end_date, r.start_date)*daily_rate*(1-discount),
DATEDIFF(r.end_date, r.start_date)*daily_rate*(1-discount)*0.8)
AS DECIMAL(8,2)) AS price
FROM rental_records AS r
INNER JOIN vehicles AS v USING (veh_reg_no)
INNER JOIN customers AS c USING (customer_id);

DESC `rental_prices`;
select * from rental_prices;
