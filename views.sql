-- All views below!

-- Annual Top Members
CREATE VIEW Annual_Top_Members(First_name, Last_name) AS
SELECT first_name, last_name,
(SELECT issued
 FROM CARD NATURAL JOIN ALLMEMBERS
 WHERE member_id = person.person_id) AS membership_date
FROM (ALLMEMBERS JOIN ORDERS ON allmembers.member_id = orders.from_customer)
		JOIN PERSON ON allmembers.member_id = person.person_id
WHERE orders.on_date > CURRENT_DATE - INTERVAL '1 year'
GROUP BY person.person_id
ORDER BY SUM(total_balance) DESC
LIMIT 3;

-- Popular Product
CREATE VIEW Popular_Product AS
SELECT *
FROM PRODUCT
WHERE product_id IN (SELECT product_id
		             FROM RECEIPT
				     GROUP BY product_id
				     ORDER BY SUM(quantity) DESC
				     LIMIT 1)


-- Potential Member Customer
create view Potential_Member_Customer(First_name, Order_count)
as
select person.first_name, count(order_id)from person inner join customer on 
person.person_id = customer.person_id inner join ORDERS on customer.person_id = ORDERS.from_customer
where customer.is_member = false and (orders.on_date > CURRENT_DATE - INTERVAL '1 month')
group by orders.from_customer, person.first_name having count(order_id) > 10


-- Gold Store
CREATE VIEW Gold_Store(Store_id, Store_name, Distinct_customers) as
SELECT store_id, sname, COUNT(DISTINCT orders.from_customer)
FROM store join orders on orders.at_store = store.store_id
WHERE (orders.on_date > CURRENT_DATE - INTERVAL '1 year')
GROUP BY store.sname, store.store_id
ORDER BY COUNT(DISTINCT from_customer) desc limit 1


-- Top Quarter Cashier
CREATE VIEW Top_Quarter_Cashier(First_name, Last_name, Number_of_orders) AS
SELECT first_name, last_name, COUNT(*)
FROM CASHIER JOIN PYMT_INFO ON cashier.person_id = pymt_info.cashier_id
            NATURAL JOIN PERSON
WHERE on_date > CURRENT_DATE - INTERVAL '3 month'
GROUP BY first_name, last_name
ORDER BY COUNT(*) DESC
LIMIT 1;
