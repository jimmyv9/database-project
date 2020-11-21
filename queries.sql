-- Find names of employees who are also members at the mall
SELECT first_name, last_name 
FROM (PERSON NATURAL JOIN EMPLOYEE)
WHERE EMPLOYEE.is_member = TRUE;

-- Find names of all cashiers, and their supervisors
SELECT first_name, last_name,
(SELECT first_name
 FROM PERSON
 WHERE fstaff_id = person.person_id) AS supervisor_fname,
(SELECT last_name
 FROM PERSON
 WHERE fstaff_id = person.person_id) AS supervisor_lname
FROM (PERSON NATURAL JOIN CASHIER);

-- Find names of all floor staff, and their supervisors
SELECT first_name, last_name,
(SELECT first_name
 FROM PERSON
 WHERE person_id = mgr_id) AS manager_first_name,
(SELECT last_name
 FROM PERSON
 WHERE person_id = mgr_id) AS manager_last_name
FROM (PERSON NATURAL JOIN FLOOR_STAFF);

-- Find names of all managers
SELECT first_name, last_name
FROM (PERSON NATURAL JOIN MANAGER);

-- Find average of orders made by potential member customers
SELECT ROUND(AVG("Orders count"), 2)
FROM POTENTIAL_MEMBER_CUSTOMER;

-- Find all customers who purchased the most popular product
SELECT first_name, last_name
FROM PERSON
WHERE person_id IN(
	SELECT DISTINCT from_customer
	FROM RECEIPT NATURAL JOIN ORDERS
	WHERE product_id IN (SELECT product_id FROM Popular_Product)
);


-- Find employees who became members after becoming employed
SELECT first_name, last_name
FROM PERSON
WHERE person_id IN (
	SELECT person_id
	FROM (EMPLOYEE JOIN ALLMEMBERS ON person_id = member_id) NATURAL JOIN CARD
	WHERE issued > start_date
);

-- Find employees who became a member one month after starting work
SELECT first_name, last_name
FROM person
WHERE person_id IN (
	SELECT person_id
	FROM (EMPLOYEE JOIN ALLMEMBERS ON person_id = member_id) NATURAL JOIN CARD
	WHERE issued > start_date AND issued < start_date + INTERVAL '1 month'
);

-- Find names members who bring the most guests
SELECT person.first_name, person.last_name, COUNT(*) AS number_of_guests
FROM PERSON JOIN GUEST ON person_id = member_id
GROUP BY person.first_name, person.last_name
ORDER BY COUNT(*) DESC
LIMIT 1;






-- 7 
-- Gives us the store id and count of the product. I DON’T KNOW if we need the store name 
select store_id, count (distinct product_id) from product_in_store group by store_id
order by count (distinct product_id) desc  limit 1

-- 8
Guessing this means staff who worked in all the floors in past 1 week

-- 9
select product_id, store_id, price from Product_in_store;

-- 10
select floor_id from Store group by floor_id 
order by count(store_id) desc limit 1

-- 11
select on_date, open_t, close_t, "Store_name" from OPEN_CLOSE_TIMES as schedule 
inner join gold_store on schedule.store_id = "Store_id"

--Simpler way to do this is the following command but it does not show the store name. So just stick to the above query
select on_date, open_t, close_t from OPEN_CLOSE_TIMES as schedule where schedule.store_id = 
(select "Store_id" from gold_store) 

-- 12
select store_id, sname from store where store_id = (
select at_store from orders 
where (orders.on_date > date('2020-01-01') - INTERVAL '1 week')
group by at_store order by count(order_id) desc limit 1)

-- 13
select person_id, first_name, last_name from person where person.person_id = (
	select mgr_id from Floor_staff group by mgr_id order by count(person_id) 
	desc limit 1
