-- ZIP
CREATE TABLE IF NOT EXISTS ZIP (
	zip VARCHAR(5) PRIMARY KEY,
	city VARCHAR(30) NOT NULL,
	us_state VARCHAR(2) NOT NULL,
	CONSTRAINT chk_state CHECK(LENGTH(us_state) = 2),
	CONSTRAINT chk_zip CHECK(LENGTH(zip) = 5),
  CONSTRAINT chk_zip_no CHECK(zip~'^[0-9]*$')
);

-- ADDRESS
CREATE SEQUENCE IF NOT EXISTS addr_seq;
CREATE TABLE IF NOT EXISTS ADDRESS (
	address_id INT DEFAULT nextval('addr_seq') PRIMARY KEY,
	zip VARCHAR(5) NOT NULL,
	street_name VARCHAR(30) NOT NULL,
	street_no VARCHAR(10) NOT NULL,
	apt_no VARCHAR(10)

	CONSTRAINT chk_zip CHECK(LENGTH(zip) = 5),
	CONSTRAINT chk_zip_no CHECK(zip~'^[0-9]*$'),
	CONSTRAINT fk_zip FOREIGN KEY(zip) REFERENCES zip(zip),
	CONSTRAINT chk_street_no CHECK(street_no~'^[0-9]*$')
);

-- PERSON
CREATE SEQUENCE IF NOT EXISTS seq;
CREATE TABLE IF NOT EXISTS PERSON (
	person_id VARCHAR(4) DEFAULT to_char(nextval('seq'), 'P000FM') PRIMARY KEY,
	first_name VARCHAR(30) NOT NULL,
	middle_name VARCHAR(30),
	last_name VARCHAR(30) NOT NULL,
	gender VARCHAR(6) NOT NULL,
	CONSTRAINT chk_gender CHECK(LOWER(gender) in ('male', 'female', 'other')),
	Dob DATE NOT NULL,
	CONSTRAINT chk_dob CHECK((date_part('year', Current_date) - date_part('year', Dob))  > 15),
	address_id INT,
	CONSTRAINT fk_addr FOREIGN KEY(address_id) REFERENCES address(address_id)
);

-- PHONE_NO
CREATE TABLE IF NOT EXISTS PHONE_NO (
	person_id VARCHAR(4) PRIMARY KEY,
	phone_no VARCHAR(10) NOT NULL,
	CONSTRAINT phone_no_size CHECK(LENGTH(phone_no) = 10),
	CONSTRAINT phone_no_size_data CHECK(phone_no~'^[0-9]*$'),
	CONSTRAINT fk_person_id FOREIGN KEY (person_id) REFERENCES person(person_id)
);

-- CUSTOMER
CREATE TABLE IF NOT EXISTS CUSTOMER (
	person_id VARCHAR(4) PRIMARY KEY,
	is_member BOOL NOT NULL DEFAULT FALSE,
	CONSTRAINT fk_person_id FOREIGN KEY(person_id)REFERENCES person(person_id)
);
                              
-- EMPLOYEE 
CREATE TABLE IF NOT EXISTS EMPLOYEE (
	person_id VARCHAR(4) PRIMARY KEY,
	start_date DATE NOT NULL,
	job_type VARCHAR(10) NOT NULL,
	is_member BOOL NOT NULL DEFAULT FALSE,
	CONSTRAINT chk_jobtype CHECK(LOWER(job_type) in ('manager', 'staff', 'cashier')),
	CONSTRAINT fk_pid FOREIGN KEY(person_id) REFERENCES person(person_id)
);                              
                              
--MANAGER
CREATE TABLE IF NOT EXISTS MANAGER(
	person_id VARCHAR(4) PRIMARY KEY,
	CONSTRAINT fk_pid FOREIGN KEY(person_id) REFERENCES employee(person_id)
);
                               
--CARD
CREATE SEQUENCE IF NOT EXISTS card_seq;
CREATE TABLE IF NOT EXISTS CARD (
	card_id VARCHAR(5) DEFAULT to_char(nextval('card_seq'), 'X000FM') PRIMARY KEY,
	issued DATE NOT NULL,
	issued_by VARCHAR(4) NOT NULL,
	CONSTRAINT fk_mgr FOREIGN KEY(issued_by) REFERENCES manager(person_id)
);
                                                              
-- MEMBER
CREATE TABLE IF NOT EXISTS ALLMEMBERS (
	member_id VARCHAR(4) PRIMARY KEY,
	card_id VARCHAR(4) NOT NULL,
	CONSTRAINT fk_membership FOREIGN KEY(member_id)REFERENCES person(person_id),
	CONSTRAINT fk_card FOREIGN KEY(card_id) REFERENCES card(card_id)
);             
                          
                              
--GUEST                    
CREATE TABLE IF NOT EXISTS GUEST (
	member_id VARCHAR(4),
	guest_id INT,
	first_name VARCHAR(30) NOT NULL,
	middle_name VARCHAR(30),
	last_name VARCHAR(30) NOT NULL,
	phone_no VARCHAR(10) NOT NULL,
	loc_id INT NOT NULL,
	PRIMARY KEY (member_id, guest_id),
	CONSTRAINT phone_no_size CHECK(LENGTH(phone_no) = 10),
	CONSTRAINT fk_locid FOREIGN KEY(loc_id) REFERENCES address(address_id),
	CONSTRAINT fk_member FOREIGN KEY (member_id) REFERENCES allmembers(member_id)
);

-- CARD_PROMOTION
CREATE TABLE IF NOT EXISTS CARD_PROMOTION (
	promotion_id INT,
	card_id VARCHAR(5),
	promotion_desc text,
	PRIMARY KEY (promotion_id, card_id),
	CONSTRAINT fk_card_id FOREIGN KEY(card_id)REFERENCES card(card_id)
);
                               
-- FLOOR STAFF
CREATE TABLE IF NOT EXISTS FLOOR_STAFF(
	person_id VARCHAR(4) PRIMARY KEY,
	mgr_id VARCHAR(4) NOT NULL,
	CONSTRAINT fk_pid FOREIGN KEY(person_id)REFERENCES employee(person_id),
	CONSTRAINT fk_mgr FOREIGN KEY(mgr_id) REFERENCES manager(person_id)
);
                               
                               
-- FLOOR
CREATE TABLE IF NOT EXISTS MALL_FLOOR (
	floor_id INT PRIMARY KEY
);
                               
-- FS_MANAGES_FLOOR
CREATE TABLE IF NOT EXISTS FS_MANAGES_FLOOR (
	floor_id INT,
	on_date DATE,
	staff_id VARCHAR(4) NOT NULL,
	PRIMARY KEY (floor_id, on_date),
	CONSTRAINT fk_floor FOREIGN KEY(floor_id) REFERENCES mall_floor(floor_id),
	
	CONSTRAINT fk_staff FOREIGN KEY(staff_id) REFERENCES floor_staff(person_id)
);
                               
-- STORE
CREATE SEQUENCE IF NOT EXISTS store_seq;
CREATE TABLE IF NOT EXISTS STORE (
	store_id VARCHAR(5) DEFAULT to_char(nextval('store_seq'), '000FM') PRIMARY KEY,
	floor_id INT,
	sname VARCHAR(20),
	stype VARCHAR(20),
	loc_id INT,
	CONSTRAINT fk_loc FOREIGN KEY(loc_id) REFERENCES address(address_id),
	CONSTRAINT fk_floor FOREIGN KEY(floor_id) REFERENCES mall_floor(floor_id)
);
                               
-- CASHIER
CREATE TABLE IF NOT EXISTS CASHIER(
	person_id VARCHAR(4) PRIMARY KEY,
	fstaff_id VARCHAR(4) NOT NULL,
	store_id VARCHAR(5) NOT NULL,
	CONSTRAINT fk_pid FOREIGN KEY(person_id) REFERENCES employee(person_id),
	CONSTRAINT fk_fstaff FOREIGN KEY(fstaff_id) REFERENCES floor_staff(person_id),
	CONSTRAINT fk_store FOREIGN KEY(store_id) REFERENCES store(store_id)
);
                               
-- ORDER
CREATE SEQUENCE IF NOT EXISTS order_seq;
CREATE TABLE IF NOT EXISTS ORDERS (
	order_id INT DEFAULT nextval('order_seq') PRIMARY KEY,
	on_date DATE DEFAULT current_date NOT NULL,
	on_time TIME DEFAULT current_time NOT NULL,
	at_store VARCHAR(5) NOT NULL,
	total_balance REAL DEFAULT 0.0 NOT NULL,
	from_customer VARCHAR(4) NOT NULL,
	
	CONSTRAINT fk_store FOREIGN KEY (at_store) REFERENCES store(store_id),
	CONSTRAINT fk_customer FOREIGN KEY (from_customer) REFERENCES customer(person_id)
);

-- PAYMENT_INFO
CREATE SEQUENCE IF NOT EXISTS payment_seq;
CREATE TABLE IF NOT EXISTS PYMT_INFO (
	payment_id INT DEFAULT nextval('payment_seq') PRIMARY KEY,
	cashier_id VARCHAR(4) NOT NULL,
	on_date DATE DEFAULT current_date NOT NULL,
	on_time TIME DEFAULT current_time NOT NULL,
	amt_paid REAL NOT NULL,
	pymt_method VARCHAR(10) NOT NULL,
	CONSTRAINT chk_method CHECK(pymt_method in ('cash', 'credit', 'debit', 'membercard')),
	CONSTRAINT fk_cashier FOREIGN KEY(cashier_id) REFERENCES cashier(person_id)
);

-- PAYMENT
CREATE TABLE IF NOT EXISTS PAYMENT (
	order_id INT PRIMARY KEY,
	customer_id VARCHAR(4),
	payment_id INT,
	CONSTRAINT fk_order FOREIGN KEY(order_id)REFERENCES orders(order_id),
	CONSTRAINT fk_customer FOREIGN KEY (customer_id)REFERENCES customer(person_id),
	CONSTRAINT fk_pymt FOREIGN KEY (payment_id) REFERENCES pymt_info(payment_id)	
);

-- PRODUCT
CREATE TABLE IF NOT EXISTS PRODUCT(
	product_id INT PRIMARY KEY,
	pname VARCHAR(20) NOT NULL,
	description VARCHAR(100)
);

-- STOCK
CREATE TABLE IF NOT EXISTS STOCK (
	stock_id INT PRIMARY KEY,
	qty INT NOT NULL
);

-- PRODUCT_IN_STORE
CREATE TABLE IF NOT EXISTS PRODUCT_IN_STORE (
	product_id INT,
	store_id VARCHAR(5),
	stock_id INT,
	price REAL NOT NULL,
	PRIMARY KEY(product_id, store_id),
	CONSTRAINT chk_price_pos CHECK(price > 0),
	CONSTRAINT fk_product FOREIGN KEY(product_id) REFERENCES product(product_id),
	CONSTRAINT fk_store FOREIGN KEY(store_id) REFERENCES store(store_id),
	CONSTRAINT fk_stock FOREIGN KEY(stock_id) REFERENCES stock(stock_id)
);
                              
-- RECEIPT
CREATE TABLE IF NOT EXISTS RECEIPT (
	product_id INT,
	order_id INT,
	quantity INT,
	PRIMARY KEY (product_id, order_id),
	CONSTRAINT fk_prod FOREIGN KEY (product_id)REFERENCES product(product_id),
	CONSTRAINT fk_order FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

--SCHEDULE                              
CREATE TABLE IF NOT EXISTS SCHEDULE (
	store_id VARCHAR(5) PRIMARY KEY,
	mgr_id VARCHAR(4) NOT NULL,
	CONSTRAINT fk_store_id FOREIGN KEY(store_id) REFERENCES store(store_id),
	CONSTRAINT fk_mgr FOREIGN KEY(mgr_id) REFERENCES manager(person_id)
);                              
                              

-- OPEN_CLOSE_TIMES
CREATE TABLE IF NOT EXISTS OPEN_CLOSE_TIMES (
	on_date DATE,
	store_id VARCHAR(5),
	open_t TIME, 
	close_t TIME,
	PRIMARY KEY(on_date, store_id),
	CONSTRAINT fk_store FOREIGN KEY(store_id) REFERENCES schedule(store_id)
);                              
                              
                               
                               
                              

