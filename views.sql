-- All views below!

-- Annual Top Members




-- Potential Member Customer
create view Potential_Member_Customer("First Name", "Orders count")
as
select person.first_name, count(order_id)from person inner join customer on 
person.person_id = customer.person_id inner join ORDERS on customer.person_id = ORDERS.from_customer
where customer.is_member = false and (orders.on_date > CURRENT_DATE - INTERVAL '1 month')
group by orders.from_customer, person.first_name having count(order_id) > 10


-- Gold Store
SELECT sname
FROM store
where store.store_id = (
select store_id from store inner join orders on 
orders.at_store = store.store_id  where (orders.on_date > CURRENT_DATE - INTERVAL '1 year') 
group by store_id order by COUNT(DISTINCT from_customer) desc limit 1)


