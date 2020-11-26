-- 1 //////////////////////////////////////////////////////////////////////////////////////////
-- Find names of employees who are also members at the mall
SELECT first_name, last_name 
FROM (PERSON NATURAL JOIN EMPLOYEE)
WHERE EMPLOYEE.is_member = TRUE;

-- 2 //////////////////////////////////////////////////////////////////////////////////////////
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

-- 3 //////////////////////////////////////////////////////////////////////////////////////////
-- Find average of orders made by potential member customers
SELECT ROUND(AVG(Order_count), 2)
FROM POTENTIAL_MEMBER_CUSTOMER;

-- 4 //////////////////////////////////////////////////////////////////////////////////////////
-- Find all customers who purchased the most popular product
SELECT first_name, last_name
FROM PERSON
WHERE person_id IN(
	SELECT DISTINCT from_customer
	FROM RECEIPT NATURAL JOIN ORDERS
	WHERE product_id IN (SELECT product_id FROM Popular_Product)
);

-- 5 //////////////////////////////////////////////////////////////////////////////////////////
-- Find employees who became a member one month after starting work
SELECT first_name, last_name
FROM person
WHERE person_id IN (
	SELECT person_id
	FROM (EMPLOYEE JOIN ALLMEMBERS ON person_id = member_id) NATURAL JOIN CARD
	WHERE issued > start_date AND issued < start_date + INTERVAL '1 month'
);

-- 6 //////////////////////////////////////////////////////////////////////////////////////////
-- Find names members who bring the most guests
SELECT person.first_name, person.last_name, COUNT(*) AS number_of_guests
FROM PERSON JOIN GUEST ON person_id = member_id
GROUP BY person.first_name, person.last_name
ORDER BY COUNT(*) DESC
LIMIT 1;



-- 7 //////////////////////////////////////////////////////////////////////////////////////////
-- Find the store that have most different products in stock.
select store_id, sname, count (distinct product_id) from product_in_store 
natural join Store group by store_id, sname
order by count (distinct product_id) desc  limit 1

-- 8 //////////////////////////////////////////////////////////////////////////////////////////
-- Find the floor staff who have token charge of all the floors in the past 1 week.
select first_name, last_name, person.person_id from person 
where person.person_id in 
(select staff_id from fs_manages_floor 
where (on_date > Current_date - INTERVAL '1 week') 
group by staff_id having count(distinct floor_id) = 3)

-- 9 //////////////////////////////////////////////////////////////////////////////////////////
-- For each product, list all the stores selling it, and the price of the product at the stores.
select pname, sname, price from Product_in_store natural join Store natural join Product;

-- 10 //////////////////////////////////////////////////////////////////////////////////////////
-- Find the floor that have the most number of stores located.
select floor_id from Store group by floor_id 
order by count(store_id) desc limit 1

-- 11 //////////////////////////////////////////////////////////////////////////////////////////
-- Find the schedule of the Gold-Store.
select on_date, open_t, close_t, Store_name from OPEN_CLOSE_TIMES as schedule 
inner join gold_store on schedule.store_id = gold_store.Store_id


-- 12 //////////////////////////////////////////////////////////////////////////////////////////
-- Find the store that produces the most sale in the past 1 week.
select store_id, sname from store where store_id = (
select at_store from orders 
where (orders.on_date > Current_date - INTERVAL '1 week')
group by at_store order by count(order_id) desc limit 1)

-- 13 //////////////////////////////////////////////////////////////////////////////////////////
-- Find the employee who supervises the most number of floor staffs.
select person_id, first_name, last_name from person where person.person_id = (
	select mgr_id from Floor_staff group by mgr_id order by count(person_id) 
	desc limit 1
	)
