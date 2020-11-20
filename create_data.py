import random
import copy
from random import randrange
from datetime import timedelta
from datetime import datetime
from numpy.random import choice

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
    def __init__(self, sname, stype, idno):
        self.sname = sname
        self.stype = stype
        self.idno = idno
        #self.stock_id = 0
        self.menu = [] # Indexes products it sells
        self.schedule = [] # Indexes days and it's schedules

    def get_id(self):
        return str(self.idno).zfill(3)

    def get_name(self):
        return self.sname

    def add_to_menu(self, prod_id, stock_id, price):
        #self.stock_id += 1
        self.menu.append((prod_id, stock_id, price))

    def pick_from_menu(self):
        return random.choice(self.menu)

def main():
    random.seed(0)
    all_people = read_people()
    all_stores = read_stores()
    make_hierarchy(all_people)
    add_to_menus(all_stores)
    program_schedule(all_stores, all_people)
    make_orders(all_people, all_stores)
    return

def read_stores():
    stores = []
    idno = 1
    with open("./populate/sql_stores.txt", 'r') as fstore:
        for line in fstore:
            line = line.strip('\n')
            line = line.split('\t')
            store_oi = store(line[1], line[2], idno)
            stores.append(store_oi)
            idno += 1
    return stores

def add_products_in_store(stores):
    products = []
    with open("./populate/sql_products.txt", 'r') as fprod:
        with open("./populate/sql_prod_in_store.txt", 'w') as fout:
            for line in fprod:
                line = line.strip('\n')
                line = line.split('\t')
                prod_id = int(line[0])
                prod_name = line[1]
                which_stores = input("Which stores sell {}?".format(prod_name))
                which_stores = which_stores.split()
                for store in which_stores:
                    price = float(input("{} sells {} for how much?".format(stores[int(store)-1].get_name(), prod_name)))
                    stores[int(store)-1].add_to_menu(prod_id, price)
                    a, b, c = stores[int(store)-1].menu[-1]
                    fout.write("{}\t{}\t{}\t{}\n".format(a, stores[int(store)-1].get_id(), b, c))

def add_to_menus(stores):
    with open("./populate/sql_prod_in_store.txt", 'r') as fin:
        for line in fin:
            line = line.strip('\n')
            line = line.split('\t')
            prod_id = int(line[0])
            store_id = int(line[1])
            stock_id = int(line[2])
            price = float(line[3])
            stores[store_id - 1].add_to_menu(prod_id, stock_id, price)

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
        store = 1
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
                                                 'X'+str(card_id).zfill(3)))
                    card_id += 1

def program_schedule(stores, people):
    """
    Programs schedule for all different stores across the years
    """
    d1 = datetime.strptime('1/1/2016', '%m/%d/%Y')
    d2 = datetime.strptime('1/1/2020', '%m/%d/%Y')
    day_count = (d2 - d1).days + 1
    manager = []
    staff = []
    for j in range(len(people)):
        if people[j].belongs_to == 'manager':
            manager.append(people[j].get_id())
        elif people[j].belongs_to == 'staff':
            staff.append(people[j].get_id())
    # Populate FS_MANAGES_FLOOR
    with open("./populate/sql_fs_manages_floor.txt", 'w') as fs:
        for date in (d1 + timedelta(n) for n in range(day_count)):
            random.shuffle(staff)
            for floor in range(1, 4):
                fs.write("{}\t{}\t{}\n".format(floor,
                                               date.strftime("%Y-%m-%d"),
                                               staff[floor-1]))

    # Populate SCHEDULE 
    with open("./populate/sql_schedule.txt", 'w') as fsch:
        for s in range(len(stores)):
            fsch.write("{}\t{}\n".format(stores[s].get_id(),
                                         manager[random.randint(0, 1)]))

    # Populate Open-Close Times
    with open("./populate/sql_open_close.txt", 'w') as foc:
        for date in (d1 + timedelta(n) for n in range(day_count)):
            for s in range(len(stores)):
                if date.weekday() <= 5:
                    foc.write("{}\t{}\t{}\t{}\n".format(date.strftime("%Y-%m-%d"),
                                                        stores[s].get_id(),
                                                        "08:00:00", "20:00:00"))
                else:
                    foc.write("{}\t{}\t{}\t{}\n".format(date.strftime("%Y-%m-%d"),
                                                        stores[s].get_id(),
                                                        "10:00:00",
                                                        "20:00:00"))


def make_orders(people, stores):
    # Get our consumers (customers)
    members = []
    nonmembers = []
    for i in range(len(people)):
        if people[i].belongs_to == 'customer':
            if people[i].ismember == True:
                members.append(people[i])
            else:
                nonmembers.append(people[i])

    # Simulate 3 past years of shopping mall 
    d1 = datetime.strptime('1/1/2016', '%m/%d/%Y')
    d2 = datetime.strptime('1/1/2020', '%m/%d/%Y')
    day_count = (d2 - d1).days + 1
    with open("./populate/sql_orders.txt", 'w') as ford:
        retail = stores[:2]
        food = stores[2:7]
        luxury = stores[7:9]
        electronics = stores[9:]
        order_id = 0
        num_list = [i for i in range(1, 11)]
        retail_prob = [0.6, 0.2, 0.1, 0.05, 0.025, 0.025, 0, 0, 0, 0]
        food_prob = [0.3, 0.15, 0.15, 0.10, 0.05, 0.05, 0.05, 0.05, 0.05, 0.05]
        for date in (d1 + timedelta(n) for n in range(day_count)):
            # Higher chance to buy stuff on weekends
            if date.weekday() <= 5:
                mem_part = 0.5
                non_part = 0.7
            else:
                mem_part = 0.3
                non_part = 0.4

            for member in members:
                if random.random() < mem_part:
                    continue
                order_id += 1
                option = random.random()
                num_items = 1
                if option < 0.005:
                    store_id, balance = make_purchase(luxury, order_id, num_items)
                elif option < 0.02:
                    if random.random() < 0.05:
                        num_items = 2
                    store_id, balance = make_purchase(electronics, order_id, num_items)
                elif option < 0.1:
                    num_items = choice(num_list, 1, p=retail_prob)[0]
                    store_id, balance = make_purchase(retail, order_id, num_items)
                elif option < 0.6:
                    num_items = choice(num_list, 1, p=food_prob)[0]
                    store_id, balance = make_purchase(food, order_id, num_items)
                ford.write("{}\t{}\t{}\t{}\t{}\t{}\n".format(order_id, date,
                                                             "13:00:00",
                                                             store_id, balance,
                                                            member.get_id()))
            for nonmember in nonmembers:
                if random.random() < mem_part:
                    continue
                order_id += 1
                option = random.random()
                num_items = 1
                if option < 0.001:
                    store_id, balance = make_purchase(luxury, order_id, num_items)
                elif option < 0.01:
                    if random.random() < 0.05:
                        num_items = 2
                    store_id, balance = make_purchase(electronics, order_id, num_items)
                elif option < 0.075:
                    num_items = choice(num_list, 1, p=retail_prob)[0]
                    store_id, balance = make_purchase(retail, order_id, num_items)
                elif option < 0.65:
                    num_items = choice(num_list, 1, p=food_prob)[0]
                    store_id, balance = make_purchase(food, order_id, num_items)
                ford.write("{}\t{}\t{}\t{}\t{}\t{}\n".format(order_id, date,
                                                             "13:00:00",
                                                             store_id, balance,
                                                            nonmember.get_id()))


def make_purchase(store_grp, order_id, n):
    total_balance = 0
    qty = {}
    for _ in range(n):
        chosen = random.choice(store_grp)
        product = chosen.pick_from_menu()
        pid = product[0]
        price = product[2]
        if pid in qty:
            qty[pid] += 1
        else:
            qty[pid] = 1
        total_balance += price

    with open("./populate/sql_receipt.txt", 'a') as frcpt:
        for value in qty:
            frcpt.write("{}\t{}\t{}\n".format(value, order_id, qty[value]))

    return chosen.get_id(), total_balance

def read_people():
    people = []
    idno = 1
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
    This function will return a random date between two datetime
    objects.
    """
    delta = end - start
    int_delta = delta.days
    random_days = randrange(int_delta)
    return start + timedelta(days=random_days)

def random_time(start, end):
    """
    This function will return a random time between two datetime
    objects.
    """
    delta = end-start
    int_delta = delta.minutes
    random_mins = randrange(int_delta)
    return start + timedelta(minutes=random_mins)

if __name__ == '__main__':
    main()
