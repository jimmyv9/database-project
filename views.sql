-- All views below!

-- Annual Top Members




-- Potential Member Customer
create view Potential_Member_Customer("First Name", "Orders count")
as
select person.first_name, count(order_id)from person inner join customer on 
person.person_id = customer.person_id inner join ORDERS on customer.person_id = ORDERS.from_customer
where customer.is_member = false and (orders.on_date > CURRENT_DATE - INTERVAL '1 month')
group by orders.from_customer, person.first_name having count(order_id) > 10
