-- -----------------------------------------------------
-- Drop the 'bikerental' database/schema
-- -----------------------------------------------------

DROP SCHEMA IF EXISTS bikerental;
-- -----------------------------------------------------
-- Create 'bikerental' database/schema and use this database
-- -----------------------------------------------------


CREATE SCHEMA IF NOT EXISTS bikerental;

USE bikerental;

-- -----------------------------------------------------
-- Drop tables
-- -----------------------------------------------------

-- drop table Employee;
-- drop table Customer;
-- drop table Booking;
-- drop table Service;
-- drop table BikeModel;
-- drop table Bike;
-- drop table BikeRequested;
-- drop table BikeUsed;
-- drop table PartUsed;



-- -----------------------------------------------------
-- Create table Employee
-- -----------------------------------------------------

create table Employee (
staffId int auto_increment not null,
fName varchar(20) not null,
lName varchar(20) not null,
hourlyRate decimal(4,2) not null, 
mechanicFlag tinyint unsigned not null default 0,
primary key (staffId)
);

-- -----------------------------------------------------
-- Create table Customer
-- (I used varchar for the phone number to preserve the leading zeros) 
-- -----------------------------------------------------

create table Customer (
emailAddress varchar(40) not null,
fName varchar(20) not null,
lName varchar(20) not null, 
phoneNumber varchar(20) not null, 
street varchar(20) not null, 
town varchar(20) not null, 
county ENUM('Antrim', 'Armagh', 'Carlow', 'Cavan', 'Clare', 'Cork', 'Derry', 'Donegal', 'Down', 'Dublin', 'Fermanagh', 'Galway', 'Kerry', 'Kildare', 'Kilkenny', 'Laois', 'Leitrim', 'Limerick', 'Longford', 'Louth', 'Mayo', 'Meath', 'Monaghan', 'Offaly', 'Roscommon', 'Sligo', 'Tipperary', 'Tyrone', 'Waterford', 'Westmeath', 'Wexford', 'Wicklow') not null, 
primary key (emailAddress)
);

-- -----------------------------------------------------
-- Create table BikeModel
-- -----------------------------------------------------

create table BikeModel (
modelId int auto_increment not null,
make varchar (20) not null, 
model varchar (20) not null, 
typeOfBike ENUM('Man', 'Woman', 'Child', 'Tandem') not null, 
primary key (modelId)
);


-- -----------------------------------------------------
-- Create table Bike
-- -----------------------------------------------------

create table Bike (
serialNumber varchar (20) not null, 
dateObtained date not null, 
dateSold date, 
modelId int not null,
primary key (serialNumber), 
constraint fk_bikemodel foreign key(modelId) references BikeModel(modelId) 
on update cascade on delete no action
);

-- -----------------------------------------------------
-- Create table Booking
-- -----------------------------------------------------


create table Booking (
bookingId int auto_increment not null,
bookingDateandTime datetime not null,
staffId int not null,
emailAddress varchar(40) not null,
primary key (bookingId),
constraint fk_staff foreign key(staffId) references Employee(staffId) 
on update cascade on delete no action,
constraint fk_customer foreign key(emailAddress) references Customer(emailAddress) 
on update cascade on delete no action
);

-- -----------------------------------------------------
-- Create table Service
-- -----------------------------------------------------

create table Service (
serviceId int auto_increment not null,
serviceDate date not null,
staffId int not null,
serialNumber varchar (20) not null, 
primary key (serviceId), 
constraint fk_mechanicService foreign key(staffId) references Employee(staffId) 
on update cascade on delete no action, 
constraint fk_bikeservice foreign key(serialNumber) references Bike(serialNumber) 
on update cascade on delete no action
);

-- -----------------------------------------------------
-- Create table Part
-- -----------------------------------------------------

create table Part(
partNumber int auto_increment not null, 
partDescription varchar(30) not null,
stockQuantity int not null default 0, 
partPrice decimal(5,2) not null,
primary key (partNumber)
); 

-- -----------------------------------------------------
-- Create table bikeRequested
-- -----------------------------------------------------
create table BikeRequested(
bookingId int not null,
modelId int not null, 
numberOfThisBikeRequested int not null default 1,
primary key(bookingId,modelId), 
constraint fk_bookingrequest foreign key(bookingId) references Booking(bookingId) 
on update cascade on delete no action,
constraint fk_bookingbike foreign key(modelId) references BikeModel(modelId) 
on update cascade on delete no action
);

-- -----------------------------------------------------
-- Create table bikeUsed
-- -----------------------------------------------------

create table BikeUsed(
bookingId int not null,
serialNumber varchar (20) not null, 
primary key (bookingId,serialNumber),
constraint fk_booking foreign key(bookingId) references Booking(bookingId) 
on update cascade on delete no action,
constraint fk_bikeused foreign key(serialNumber) references Bike(serialNumber) 
on update cascade on delete no action
);

-- -----------------------------------------------------
-- Create table partUsed
-- -----------------------------------------------------

create table partUsed(
serviceId int not null, 
partNumber int not null, 
quantityUsed tinyint unsigned not null default 1, 
primary key (serviceId,partNumber), 
constraint fk_partservice foreign key(serviceId) references Service(serviceId) 
on update cascade on delete no action, 
constraint fk_partnumber foreign key(partNumber) references Part(partNumber) 
on update cascade on delete no action
);

-- ------------------------------------------------------------------------------------------
-- Trigger to update a table of last service date for each bike when a service is inserted 
-- ------------------------------------------------------------------------------------------
create table LastService(
serialNumber varchar (20) not null,
lastServiceDate date, 
primary key (serialNumber,lastServiceDate),
constraint fk_serial foreign key(serialNumber) references Bike(serialNumber) 
on update cascade on delete no action
);

-- when a new bike is obtained, automatically insert the date Obtained as the last service 

DELIMITER $$
CREATE TRIGGER after_bike_insert
    AFTER INSERT ON bike
    FOR EACH ROW 
BEGIN
	delete from LastService where serialNumber = NEW.serialNumber;
    INSERT into LastService values
	(NEW.serialNumber,NEW.dateObtained);
END $$
DELIMITER ;

-- delete any exisitng last service entry for the bike and then insert the new last service entry: 

DELIMITER $$
CREATE TRIGGER after_service_insert
    AFTER INSERT ON service
    FOR EACH ROW 
BEGIN
	delete from LastService where serialNumber = NEW.serialNumber;
    INSERT into LastService values
	(NEW.serialNumber,NEW.servicedate);
END $$
DELIMITER ;

-- ------------------------------------------------------------------------------------------------
-- Trigger to deduct stockQuantity of Part by the quantityUsed value when Partused table is inserted 
-- (keeps the stockQuantity up to date after a part is used)
-- ------------------------------------------------------------------------------------------------

DELIMITER $$
CREATE TRIGGER after_partused_insert
    AFTER INSERT ON partused
    FOR EACH ROW 
BEGIN
    UPDATE part
    SET stockquantity  = stockquantity - NEW.quantityused
    WHERE partNumber = NEW.partnumber;
END $$
DELIMITER ;

-- -----------------------------------------------------
-- Populate table Employee
-- -----------------------------------------------------

insert into Employee (fName, lName, hourlyRate) values
('John','Lennon',13.00),
('Paul','McCartney',13.00),
('George','Harrison',13.00),
('Ringo','Starr',13.00);
insert into Employee (fName, lName, hourlyRate,mechanicFlag) values
('Brian','Epstein',15.00,1),
('George','Martin',15.00,1);

-- -----------------------------------------------------
-- Populate table Customer
-- ----------------------------------------------------

insert into Customer values
('bertie@fagans.com','Bertie','Ahern','018082345','Griffith Avenue','Drumcondra','Dublin'),
('michael@healyraes.com','Michael','HealyRae','0648088123','Main Street','Kilgarvan','Kerry'), 
('mary@shannon.com','Mary','ORourke','0907893454','Barrack Street','Athlone','Westmeath'),
('helen@boyne.com','Helen','McEntee','0465673456','Main Street','Navan','Meath');

-- -----------------------------------------------------
-- Populate table BikeModel
-- ----------------------------------------------------
insert into BikeModel (make,model,typeOfBike) values
('Raleigh','Detour','Man'),
('Carrera','Crossfire','Man'),
('Raleigh','Detour','Woman'),
('Carrera','Crossfire','Woman'),
('Carrera','Subway','Child'),
('Pendeton','Blossomby','Child'),
('Discovery','Twin','Tandem');



-- -----------------------------------------------------
-- Populate table Bike
-- ----------------------------------------------------
insert into Bike (serialNumber,dateObtained,modelId) values
('RD54762','2018-03-23',1),
('RD45387','2018-03-23',1),
('CC12345','2017-12-04',2),
('CC11232','2017-12-04',2),
('RD67876','2018-08-12',3),
('RD88975','2018-08-12',3),
('CC65678','2018-03-23',4),
('CC32343','2018-03-23',4),
('CS56544','2019-01-29',5),
('CS56434','2019-01-29',5),
('PB56433','2019-02-12',6),
('PB78656','2019-02-12',6),
('DT23214','2019-10-02',7),
('DT67876','2019-10-02',7);
insert into Bike values 
('RD54343','2017-02-11','2019-01-15',1),
('RD32311','2017-12-04','2019-01-15',3);

-- -----------------------------------------------------
-- Populate table Booking
-- ----------------------------------------------------
insert into Booking (bookingDateAndTime,staffId,emailAddress) values
('2020-03-26 11:00:00',3,'mary@shannon.com'),
('2020-06-12 08:30:00',4,'michael@healyraes.com'),
('2021-04-05 09:00:00',2,'bertie@fagans.com'),
('2021-06-23 10:00:00',1,'helen@boyne.com'),
('2020-11-22 10:00:00',3,'michael@healyraes.com');



-- -----------------------------------------------------
-- Populate table Service
-- ----------------------------------------------------

insert into Service (serviceDate,staffId,serialNumber) values
('2020-02-14',5,'RD54762'),
('2020-02-20',6,'RD45387'),
('2020-03-02',5,'CC12345'),
('2020-03-03',6,'CC11232'),
('2020-07-30',6,'RD54762'),
('2020-10-16',6,'CC12345');

-- -----------------------------------------------------
-- Populate table Part
-- ----------------------------------------------------

insert into Part (partdescription,stockQuantity,partPrice) values
('brake pad',20,2.00),
('brake cable',15,5.00),
('derailleur',10,20.00),
('chain',8,10.00),
('gear shifter',5,15.00), 
('handlegrip',10,3.00),
('pedal',5,10.00);

-- -----------------------------------------------------
-- Populate table BikeRequested
-- ----------------------------------------------------
insert into BikeRequested values
(1,1,1),
(1,3,1),
(2,1,1),
(2,4,1),
(2,6,2),
(3,7,1),
(4,3,1),
(4,5,2);
-- -----------------------------------------------------
-- Populate table BikeUsed
-- ----------------------------------------------------
insert into BikeUsed values
(1,'RD45387'),
(1,'RD88975'),
(2,'RD54762'),
(2,'CC32343'),
(2,'PB56433'),
(2,'PB78656');
-- -----------------------------------------------------
-- Populate table PartUsed
-- ----------------------------------------------------
insert into PartUsed values
(1,1,4),
(1,6,2),
(2,1,4),
(2,3,1),
(3,5,2),
(3,4,1),
(4,7,2),
(4,5,2);




-- ------------------------------------------------------------------------------------------------
-- Create indexes for commonly queried columns 
-- ------------------------------------------------------------------------------------------------
create index bikemakeind on BikeModel(make);
create index bikemodelind on BikeModel(model);
create index bookingdateandtimeind on Booking(bookingDateAndTime);
create index servicedateind on Service(serviceDate);
create index partdescriptionind on Part(partDescription);
create index partstockquantity on Part(stockQuantity);
create index bikerequestednumberind on BikeRequested(numberOfThisBikeRequested);  

-- ------------------------------------------------------------------------------------------------
-- Create user view for current booking details   
-- ------------------------------------------------------------------------------------------------

create view currentbookings as 

	select concat(fname,' ',lname) as Name, concat(make,' ',model) as Bike, typeofBike as 'Bike Type', bookingDateAndTime as BookingDate 
	from bikeModel
    natural join bikeRequested 
    natural join booking
    natural join customer 
    where bookingDateAndTime > now();
    
    -- ------------------------------------------------------------------------------------------------
-- Create user view for record of old booking details   
-- ------------------------------------------------------------------------------------------------
create view oldbookings as 

	select concat(fname,' ',lname) as Name, serialNumber as Bike, typeofBike as 'Bike Type', bookingDateAndTime as BookingDate 
	from bikeModel
    natural join bike
    natural join bikeUsed
    natural join booking
    natural join customer 
    where bookingDateAndTime < now()
    order by lname, fname;
    
-- ------------------------------------------------------------------------------------------------
-- Create user view for current bikes in stock  
-- ------------------------------------------------------------------------------------------------

create view currentbikes as
	
    select concat(make,' ',model) as Bike, typeOfBike as Type, serialNumber as 'Serial Number', dateObtained as 'Date of Purchase'
    from bikeModel
    natural join bike
    where dateSold is null;
 
 -- ------------------------------------------------------------------------------------------------
-- Create user view for sold bikes no longer in stock  
-- ------------------------------------------------------------------------------------------------
    
create view oldbikes as
	
    select concat(make,' ',model) as Bike, typeOfBike as Type, serialNumber as 'Serial Number', dateSold as 'Date Sold'
    from bikeModel
    natural join bike
    where dateSold is not null;
    





 







