import random
import copy
from random import randrange
from datetime import timedelta
from datetime import datetime

class person:
    def __init__(self, fname, lname, idno):
        self.fname = fname
        self.lname = lname
        self.idno = idno
        self.ismember = bool(random.getrandbits(1))
        self.belongs_to = None

    def set_type(self, my_type):
        self.belongs_to = my_type

    def get_id(self):
        return 'P'+str(self.idno).zfill(3)

class store:
    def __init__(self, sname, idno):
        self.sname = sname
        self.idno = idno

def main():
    random.seed(0)
    all_people = read_people()
    all_stores = read_stores()
    make_hierarchy(all_people)

    return

def read_stores():
    stores = []
    idno = 1
    with open("./populate/sql_stores.txt", 'r') as fstore:
        for line in fstore:
            line = line.strip('\n')
            line = line.split('\t')
            store_oi = store(line[1], idno)
            stores.append(store_oi)
            idno += 1
    return stores


def make_addr():
    with open("./populate/sql_zip.txt",'w') as fzip:
        fzip.write("zip\tcity\tstate\n")
        fzip.write("38112\tMemphis\tTN\n")
        fzip.write("75248\tDallas\tTX\n")
        fzip.write("90210\tHollywood\tCA\n")
    with open("./populate/sql_addr.txt", 'w') as faddr:
        faddr.write("address_id\tzip\tstreet_name\tstreet_no\n")
        faddr.write("1\t38112\tN Parkway\t2000\n")
        faddr.write("2\t75248\tCoit Rd\t560\n")
        faddr.write("3\t90210\tHollywood Blvd\t6100\n")

def make_people(addr_count):
    people = []
    d1 = datetime.strptime('1/1/1960', '%m/%d/%Y')
    d2 = datetime.strptime('1/1/2002', '%m/%d/%Y')
    with open("./populate/names.txt", 'r') as fin:
        with open("./populate/sql_names.txt", 'w') as fout:
            fout.write("first_name\tlast_name\tgender\tdob\taddress_id\n")
            for line in fin:
                gender = assign_gender(line)
                line = line.strip('\n')
                line = line.split()
                p = person(line[0], line[1])
                people.append(p)
                dob = random_date(d1, d2).strftime("%Y-%m-%d")
                addr = random.randint(1, addr_count) # Figure out where they live
                fout.write("{}\t{}\t{}\t{}\t{}\n".format(line[0], line[1], gender, dob, addr))

def make_hierarchy(people):
    random.shuffle(people)
    d1 = datetime.strptime('1/1/2017', '%m/%d/%Y')
    d2 = datetime.strptime('1/1/2020', '%m/%d/%Y')
    with open('./populate/sql_employee.txt', 'w') as femp:
        managers = people[:2]
        staff = people[2:5]
        cashiers = people[5:16]
        for i in range(16):
            if i < 2:
                jobtype = 'manager'
            elif i < 5:
                jobtype = 'staff'
            else:
                jobtype = 'cashier'

            people[i].set_type(jobtype)
            date = random_date(d1, d2).strftime("%Y-%m-%d")
            femp.write('{}\t{}\t{}\t{}\n'.format(people[i].get_id(), date,
                                               jobtype, people[i].ismember))



    with open('./populate/sql_customer.txt', 'w') as fcust:
        customers = people[16:]
        for i in range(16, 30):
            people[i].set_type('customer')
            fcust.write('{}\t{}\n'.format(people[i].get_id(),
                                          people[i].ismember))

    with open('./populate/sql_cashier.txt', 'w') as fcash:
        store = 0
        for i in range(30):
            if people[i].belongs_to == 'cashier':
                fcash.write('{}\t{}\t{}\n'.format(people[i].get_id(),
                                                  people[random.randint(2,4)].get_id(),
                                                 str(store).zfill(3)))
                store += 1

    with open('./populate/sql_fstaff.txt', 'w') as fstaff:
        for i in range(30):
            if people[i].belongs_to == 'staff':
                fstaff.write('{}\t{}\n'.format(people[i].get_id(),
                                               people[random.randint(0,1)].get_id()))

    with open('./populate/sql_manager.txt', 'w') as fmgr:
        for i in range(30):
            if people[i].belongs_to == 'manager':
                fmgr.write('{}\n'.format(people[i].get_id()))


    with open('./populate/sql_member.txt', 'w') as fmem:
        managers = people[:2]
        with open('./populate/sql_card.txt', 'w') as fcard:
            card_id = 0
            for i in range(30):
                if people[i].ismember:
                    date = random_date(d1, d2).strftime("%Y-%m-%d")
                    fcard.write('{}\t{}\n'.format(date,
                                                  people[random.randint(0,1)].get_id()))
                    fmem.write('{}\t{}\n'.format(people[i].get_id(),
                                                 'CX'+str(card_id).zfill(3)))

def read_people():
    people = []
    idno = 0
    with open("./populate/sql_names.txt", 'r') as fin:
        for line in fin:
            line = line.strip('\n')
            line = line.split('\t')
            this_person = person(line[0], line[1], idno)
            people.append(this_person)
            idno += 1
    return people

def assign_gender(person):
    g = input("What gender is {}?".format(person))
    return g

def random_date(start, end):
    """
    This function will return a random datetime between two datetime
    objects.
    """
    delta = end - start
    int_delta = delta.days
    random_second = randrange(int_delta)
    return start + timedelta(days=random_second)

if __name__ == '__main__':
    main()
