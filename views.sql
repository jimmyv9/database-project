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




-- Potential Member Customer - tested on sample data
create view Potential_Member_Customer("First Name", "Orders count")
as
select person.first_name, count(order_id)from person inner join customer on 
person.person_id = customer.person_id inner join ORDERS on customer.person_id = ORDERS.from_customer
where customer.is_member = false and (orders.on_date > CURRENT_DATE - INTERVAL '1 month')
group by orders.from_customer, person.first_name having count(order_id) > 10


-- Gold Store - tested on sample data
create view Gold_Store("Store name")
as
SELECT sname
FROM store
where store.store_id = (
select store_id from store inner join orders on 
orders.at_store = store.store_id  where (orders.on_date > CURRENT_DATE - INTERVAL '1 year') 
group by store_id order by COUNT(DISTINCT from_customer) desc limit 1)


