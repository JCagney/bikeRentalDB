 -- ------------------------------------------------------------------------------------------------
-- to select from the views 	
-- ------------------------------------------------------------------------------------------------
select * from currentbookings;
select * from oldbookings;
select * from currentbikes;
select * from oldbikes;

 -- ------------------------------------------------------------------------------------------------
-- select query to see the quantity of each type of bike currently in the shop 	
-- ------------------------------------------------------------------------------------------------
select concat(make,' ',model) as Bike, typeOfBike as Type, count(serialNumber) as Quantity
    from bikeModel
    natural join bike
    where dateSold is null
    group by bike, type;
    
    
-- ------------------------------------------------------------------------------------------------
-- select query to see quantity of adult bikes currently in the shop 
-- ------------------------------------------------------------------------------------------------
select concat(make,' ',model) as Bike, typeOfBike as Type, count(serialNumber) as Quantity
from bikeModel
natural join bike
where typeofbike in('Man','Woman','Tandem') and dateSold is null
group by bike, type;
    
-- ------------------------------------------------------------------------------------------------
-- select query to see all bookings made in 2020
-- ------------------------------------------------------------------------------------------------
select concat(fname,' ',lname) as Name, bookingDateAndTime as BookingDate 
from booking 
natural join customer
where bookingDateAndTime between '2020-01-01 00:00:00' and '2020-12-31 23:59:59';
-- ------------------------------------------------------------------------------------------------
-- select query to see all bookings for today 
-- ------------------------------------------------------------------------------------------------
select bookingId, concat(fname,' ',lname) as Name, substring(bookingdateAndTime, 12,5) as 'Booking Time'
from booking natural join customer 
where bookingId IN 
	(select bookingId from
	booking 
    where substring(bookingdateAndTime, 1,10) = curdate());
 
select* from booking;
-- ------------------------------------------------------------------------------------------------
-- select query to see number of bookings made by each employee 
-- ------------------------------------------------------------------------------------------------
select concat(fname,' ',lname) as Name, count(bookingId) as 'Bookings Made'
from booking 
natural join employee
group by bookingId;

-- ------------------------------------------------------------------------------------------------
-- select query to see number of services done by each mechanic 
-- ------------------------------------------------------------------------------------------------

select concat(fname,' ',lname) as Mechanic, count(serviceId) as 'Services Done'
from service 
natural join employee
group by mechanic;
select * from booking;
-- ------------------------------------------------------------------------------------------------
-- select query to see bikes that have not been serviced in the last 6 months 
-- ------------------------------------------------------------------------------------------------

select serialNumber, concat(make,' ',model) as Bike, lastservicedate as "Last Service", DATEDIFF( curdate(),lastservicedate) as 'Days Since Last Service'
from bikeModel
natural join bike 
natural join lastservice
where DATEDIFF( curdate(),lastservicedate) > 182 
order by lastservicedate;



-- ------------------------------------------------------------------------------------------------
-- select query to see the number of times each bike has been hired 
-- ------------------------------------------------------------------------------------------------

select concat(make,' ',model) as Bike, serialNumber as 'Serial Number', count(bookingid) as 'Number of Times Hired'
from bikemodel
natural join bike 
natural left join bikeused
natural left join booking
group by serialnumber;  

select * from bike;




-- ------------------------------------------------------------------------------------------------
-- create users Mechanic and Assistant and grant appropriate privileges
-- ------------------------------------------------------------------------------------------------

create user Mechanic identified by 'password'; 
grant all on bikerental.* to Mechanic; 

create user assistant identified by 'password'; 
grant all on customer to assistant; 
grant all on booking to assistant; 
grant all on bikerequested to assistant;
grant all on bikeused to assistant;
grant select on employee to assistant;
grant select on bikemodel to assistant;
grant select on bike to assistant;
grant select on service to assistant; 

