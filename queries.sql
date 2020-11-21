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


