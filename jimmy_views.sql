-- All views below!

-- Annual Top Members
CREATE VIEW [Annual Top Members] AS
SELECT first_name, last_name,
(SELECT issued
 FROM CARD NATURAL JOIN ALLMEMBERS
 WHERE member_id = person.person_id) AS membership_date
FROM PERSON JOIN ORDERS ON person.person_id = orders.customer_id
WHERE orders.on_date > CURRENT_DATE - INTERVAL '1 year'
GROUP BY person.person_id
ORDER BY SUM(total_balance) DESC
LIMIT 3;


-- Popular Product
CREATE VIEW [Popular Product] AS
SELECT *
FROM PRODUCT
WHERE product_id IN (SELECT product_id, SUM(quantity)
		             FROM RECEIPT
				     GROUP BY product_id
				     ORDER BY SUM(quantity)
				     LIMIT 1)
