-- Ensures that EMPLOYEE and CUSTOMER are disjoint sets of PERSON
CREATE OR REPLACE FUNCTION check_disjoint_people()
RETURNS TRIGGER AS
$func$
DECLARE
	opposite VARCHAR(10);
	res text;
BEGIN
	opposite := TG_ARGV[0];
	EXECUTE 'SELECT * FROM '|| opposite ||
			' WHERE '|| opposite ||'.person_id = $1.person_id'
	USING NEW
	INTO res;
	IF (res <> '') THEN
		RAISE EXCEPTION 'Cannot insert because it is not disjoint';
	END IF;
	RETURN NEW;
END
$func$ LANGUAGE plpgsql;

-- Triggers responsible for checking for disjointedness between
-- EMPLOYEE and CUSTOMER
CREATE TRIGGER check_disjointedness
BEFORE INSERT ON CUSTOMER
FOR EACH ROW EXECUTE PROCEDURE check_disjoint_people('EMPLOYEE');

CREATE TRIGGER check_disjointedness
BEFORE INSERT ON EMPLOYEE
FOR EACH ROW EXECUTE PROCEDURE check_disjoint_people('CUSTOMER');

-- Verifies whether an added employee subclass belongs in fact to the job type
CREATE OR REPLACE FUNCTION check_jobtype()
RETURNS TRIGGER AS
$func$
DECLARE
	jtype VARCHAR(10);
BEGIN
	jtype := TG_ARGV[0];
	IF ((SELECT job_type FROM EMPLOYEE WHERE employee.person_id = NEW.person_id) <> jtype) THEN
		RAISE EXCEPTION 'This employee does not have appropriate job type';
	END IF;
	RETURN NEW;
END
$func$ LANGUAGE plpgsql;

-- Triggers associated with position types at the mall for their respective
-- relations: MANAGER, FLOOR_STAFF, and CASHIER
CREATE TRIGGER checks_manager
BEFORE INSERT ON MANAGER
FOR EACH ROW EXECUTE PROCEDURE check_jobtype('manager');

CREATE TRIGGER checks_fstaff
BEFORE INSERT ON FLOOR_STAFF
FOR EACH ROW EXECUTE PROCEDURE check_jobtype('staff');

CREATE TRIGGER checks_cashier
BEFORE INSERT ON CASHIER
FOR EACH ROW EXECUTE PROCEDURE check_jobtype('cashier');

-------------------

-- Verifies whether an added member is either an employee or a customer
CREATE OR REPLACE FUNCTION update_membership()
RETURNS TRIGGER AS
$func$
DECLARE
	operation VARCHAR(4);
BEGIN
	operation := TG_ARGV[0];
	IF (operation = 'add') THEN
		IF (EXISTS(SELECT * FROM CUSTOMER WHERE customer.person_id = NEW.member_id)) THEN
			UPDATE CUSTOMER
			SET is_member = TRUE
			WHERE person_id = NEW.member_id;
		ELSE
			UPDATE EMPLOYEE
			SET is_member = TRUE
			WHERE person_id = NEW.member_id;
		END IF;
		RETURN NEW;
	END IF;
	IF (operation = 'del') THEN
		IF (EXISTS(SELECT * FROM CUSTOMER WHERE customer.person_id = OLD.member_id)) THEN
			UPDATE CUSTOMER
			SET is_member = FALSE
			WHERE person_id = OLD.member_id;
		ELSE
			UPDATE EMPLOYEE
			SET is_member = FALSE
			WHERE person_id = OLD.member_id;
		END IF;
		RETURN OLD;
	END IF;
END
$func$ LANGUAGE plpgsql;

-- Triggers associated with inserting or deleting instances in MEMBER change
-- the membership status of customers and employees
CREATE TRIGGER add_member
AFTER INSERT ON ALLMEMBERS
FOR EACH ROW EXECUTE PROCEDURE update_membership('add');

CREATE TRIGGER remove_member
AFTER DELETE ON ALLMEMBERS
FOR EACH ROW EXECUTE PROCEDURE update_membership('del');
