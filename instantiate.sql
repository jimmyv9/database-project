-- CREATES DATABASE

CREATE TABLE IF NOT EXISTS ZIP (
	zip VARCHAR(5) PRIMARY KEY,
	city VARCHAR(30) NOT NULL,
	us_state VARCHAR(3) NOT NULL,
	CONSTRAINT chk_state CHECK(LENGTH(us_state) = 2)
);

CREATE SEQUENCE IF NOT EXISTS addr_seq;
CREATE TABLE IF NOT EXISTS ADDRESS (
	address_id INT DEFAULT nextval('addr_seq') PRIMARY KEY,
	zip VARCHAR(5) NOT NULL,
	CONSTRAINT chk_zip CHECK(LENGTH(zip) = 5),
	CONSTRAINT chk_zip_no CHECK(zip~'^[0-9]*$'),
	CONSTRAINT fk_zip FOREIGN KEY(zip)
		REFERENCES zip(zip),
	street_name VARCHAR(30) NOT NULL,
	street_no VARCHAR(10) NOT NULL,
	CONSTRAINT chk_street_no CHECK(street_no~'^[0-9]*$'),
	apt_no VARCHAR(10)
);

CREATE SEQUENCE IF NOT EXISTS store_seq;
CREATE TABLE IF NOT EXISTS STORE (
	store_id CHAR(5) DEFAULT to_char(nextval('store_seq'), 'ST000FM') PRIMARY KEY,
	floor_id INT,
	sname VARCHAR(20),
	stype VARCHAR(20),
	loc_id INT,
	CONSTRAINT fk_loc FOREIGN KEY(loc_id)
		REFERENCES address(address_id)
);

CREATE SEQUENCE IF NOT EXISTS seq;
CREATE TABLE IF NOT EXISTS PERSON (
	person_id CHAR(4) NOT NULL DEFAULT to_char(nextval('seq'), 'P000FM') PRIMARY KEY,
	first_name VARCHAR(30) NOT NULL,
	middle_name VARCHAR(30),
	last_name VARCHAR(30) NOT NULL,
	gender VARCHAR(6) NOT NULL,
	CONSTRAINT chk_gender CHECK(LOWER(gender) in ('male', 'female', 'other')),
	Dob DATE NOT NULL,
	CONSTRAINT chk_dob CHECK((date_part('year', Current_date) - date_part('year', Dob))  > 15),
	address_id INT,
	CONSTRAINT fk_addr
		FOREIGN KEY(address_id)
			REFERENCES address(address_id)
);

CREATE TABLE IF NOT EXISTS PHONE_NO (
	person_id CHAR(4) PRIMARY KEY,
	phone_no VARCHAR(10) NOT NULL,
	CONSTRAINT phone_no_size CHECK(LENGTH(phone_no) = 10),
	CONSTRAINT fk_person_id FOREIGN KEY (person_id)
		REFERENCES person(person_id)
);

CREATE TABLE IF NOT EXISTS CUSTOMER (
	person_id CHAR(4) PRIMARY KEY,
	is_member BOOL NOT NULL DEFAULT FALSE,
	CONSTRAINT fk_person_id FOREIGN KEY(person_id)
		REFERENCES person(person_id)
);

CREATE TABLE IF NOT EXISTS EMPLOYEE (
	person_id CHAR(4) PRIMARY KEY,
	start_date DATE NOT NULL,
	job_type VARCHAR(10) NOT NULL,
	is_member BOOL NOT NULL DEFAULT FALSE,
	CONSTRAINT chk_jobtype CHECK(LOWER(job_type) in ('manager', 'staff', 'cashier')),
	CONSTRAINT fk_pid FOREIGN KEY(person_id)
		REFERENCES person(person_id)
);

CREATE TABLE IF NOT EXISTS MANAGER(
	person_id CHAR(4) PRIMARY KEY,
	CONSTRAINT fk_pid FOREIGN KEY(person_id)
		REFERENCES employee(person_id)
);

CREATE TABLE IF NOT EXISTS FLOOR_STAFF(
	person_id CHAR(4) PRIMARY KEY,
	mgr_id CHAR(4) NOT NULL,
	CONSTRAINT fk_pid FOREIGN KEY(person_id)
		REFERENCES employee(person_id),
	CONSTRAINT fk_mgr FOREIGN KEY(mgr_id)
		REFERENCES manager(person_id)
);

CREATE TABLE IF NOT EXISTS CASHIER(
	person_id CHAR(4) PRIMARY KEY,
	fstaff_id CHAR(4) NOT NULL,
	store_id CHAR(5) NOT NULL,
	CONSTRAINT fk_pid FOREIGN KEY(person_id)
		REFERENCES employee(person_id),
	CONSTRAINT fk_fstaff FOREIGN KEY(fstaff_id)
		REFERENCES floor_staff(person_id),
	CONSTRAINT fk_store FOREIGN KEY(store_id)
		REFERENCES store(store_id)
);

CREATE SEQUENCE IF NOT EXISTS card_seq;
CREATE TABLE IF NOT EXISTS CARD (
	card_id CHAR(5) NOT NULL DEFAULT to_char(nextval('card_seq'), 'CX000FM') PRIMARY KEY,
	issued DATE NOT NULL,
	issued_by CHAR(4) NOT NULL,
	CONSTRAINT fk_mgr FOREIGN KEY(issued_by)
		REFERENCES manager(person_id)
);

CREATE TABLE IF NOT EXISTS ALLMEMBERS (
	member_id CHAR(4) PRIMARY KEY,
	card_id CHAR(4) NOT NULL,
	CONSTRAINT fk_membership FOREIGN KEY(member_id)
		REFERENCES person(person_id),
	CONSTRAINT fk_card FOREIGN KEY(card_id)
		REFERENCES card(card_id)
);

CREATE TABLE IF NOT EXISTS FLOOR (
	floor_id INT NOT NULL PRIMARY KEY
);

CREATE TABLE IF NOT EXISTS PRODUCT(
	product_id INT PRIMARY KEY,
	pname VARCHAR(20) NOT NULL,
	description VARCHAR(100)
);

CREATE TABLE IF NOT EXISTS STOCK (
	stock_id INT PRIMARY KEY,
	qty INT NOT NULL
);

CREATE TABLE IF NOT EXISTS PRODUCT_IN_STORE (
	product_id INT,
	store_id CHAR(5),
	stock_id INT,
	price REAL NOT NULL,
	PRIMARY KEY(product_id, store_id),
	CONSTRAINT chk_price_pos CHECK(price > 0),
	CONSTRAINT fk_product FOREIGN KEY(product_id)
		REFERENCES product(product_id),
	CONSTRAINT fk_store FOREIGN KEY(store_id)
		REFERENCES store(store_id)
);