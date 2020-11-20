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
