create database coffeeShopSales;

use coffeeShopSales;

select * from coffee;
SET SQL_SAFE_UPDATES = 0;
update coffee
set transaction_date = str_to_date(transaction_date, '%d-%m-%Y');

alter table coffee
modify column transaction_date date;
describe coffee;

update coffee
set transaction_time = str_to_date(transaction_time, '%H:%i:%s');

alter table coffee
modify column transaction_time time;

alter table coffee
change column ï»¿transaction_id transaction_id int;


-- TOTAL SALES for each month
select monthname(transaction_date), sum(unit_price * transaction_qty) as totalsales from coffee
group by monthname(transaction_date);


-- month on month increase and decrease in sales
select month(transaction_date) as months,
	round(count(transaction_id)) AS total_orders,
	(count(transaction_id) - LAG(count(transaction_id), 1) 
	over (order by month(transaction_date))) / lag(COUNT(transaction_id), 1) 
	over (order by month(transaction_date)) * 100 as mom_increase_percentage from coffee
group by month(transaction_date)
order by month(transaction_date);


-- TOTAL QUANTITY SOLD
select monthname(transaction_date), SUM(transaction_qty) as Total_Quantity_Sold from coffee 
group by monthname(transaction_date);


-- TOTAL QUANTITY SOLD KPI - MOM DIFFERENCE AND MOM GROWTH
select month(transaction_date) as months,
    round(sum(transaction_qty)) as total_quantity_sold,
    (sum(transaction_qty) - lag(sum(transaction_qty), 1) 
    over (order by month(transaction_date))) / lag(sum(transaction_qty), 1) 
    over (order by month(transaction_date)) * 100 as mom_increase_percentage from coffee
group by month(transaction_date)
order by month(transaction_date);


-- CALENDAR TABLE – DAILY SALES, QUANTITY and TOTAL ORDERS
select transaction_date, round(sum(unit_price * transaction_qty),2) as total_sales, sum(transaction_qty) as total_quantity_sold, count(transaction_id) as total_orders from coffee
group by transaction_date;

-- SALES TREND OVER PERIOD
select avg(total_sales) as average_sales
from(select sum(unit_price * transaction_qty) as total_sales from coffee
     group by transaction_date) as avgTable;


-- DAILY SALES FOR MONTH SELECTED
select day(transaction_date) as day_of_month, round(sum(unit_price * transaction_qty),1) as total_sales from coffee
where month(transaction_date) = 5
group by day(transaction_date)
order by day(transaction_date);


-- COMPARING DAILY SALES WITH AVERAGE SALES – IF GREATER THAN “ABOVE AVERAGE” and LESSER THAN “BELOW AVERAGE”
select day_of_month,
    case 
        when total_sales > avg_sales then 'Above Average'
        when total_sales < avg_sales then 'Below Average'
        else 'Average'
    end as sales_status, total_sales
from (select day(transaction_date) as day_of_month, sum(unit_price * transaction_qty) as total_sales, avg(sum(unit_price * transaction_qty)) over () as avg_sales from coffee
      where month(transaction_date) = 5  -- Filter for May
      group by day(transaction_date)) as sales_data
order by day_of_month;


-- SALES BY WEEKDAY / WEEKEND:
select case 
		   when dayofweek(transaction_date) in (1, 7) then 'Weekends'
           else 'Weekdays'
	   end as day_type, round(sum(unit_price * transaction_qty),2) as total_sales
from coffee
where month(transaction_date) = 5  -- Filter for May
group by case 
			when dayofweek(transaction_date) in (1, 7) then 'Weekends'
			else 'Weekdays'
		 end;


-- SALES BY STORE LOCATION
select store_location, sum(unit_price * transaction_qty) as Total_Sales from coffee
where month(transaction_date) =5 
group by store_location
order by sum(unit_price * transaction_qty) desc;


-- SALES BY PRODUCT CATEGORY
select product_category, round(sum(unit_price * transaction_qty),1) as Total_Sales from coffee
where month(transaction_date) = 5 
group by product_category
order by sum(unit_price * transaction_qty) desc;


-- SALES BY PRODUCTS (TOP 10)
select product_type, round(sum(unit_price * transaction_qty),1) as Total_Sales from coffee
where month(transaction_date) = 5 
group by product_type
order by SUM(unit_price * transaction_qty) desc limit 10;


-- SALES BY DAY | HOUR
select round(sum(unit_price * transaction_qty)) as Total_Sales, sum(transaction_qty) as Total_Quantity, count(*) as Total_Orders from coffee
where dayofweek(transaction_date) = 3 and hour(transaction_time) = 8 and month(transaction_date) = 5;


-- TO GET SALES FROM MONDAY TO SUNDAY FOR MONTH OF MAY
select
    case 
        when dayofweek(transaction_date) = 2 then 'Monday'
        when dayofweek(transaction_date) = 3 then 'Tuesday'
        when dayofweek(transaction_date) = 4 then 'Wednesday'
        when dayofweek(transaction_date) = 5 then 'Thursday'
        when dayofweek(transaction_date) = 6 then 'Friday'
        when dayofweek(transaction_date) = 7 then 'Saturday'
        else 'Sunday'
    end as Day_of_Week, round(sum(unit_price * transaction_qty)) as Total_Sales
from coffee
where month(transaction_date) = 5 -- Filter for May (month number 5)
group by 
    case 
        when dayofweek(transaction_date) = 2 then 'Monday'
        when dayofweek(transaction_date) = 3 then 'Tuesday'
        when dayofweek(transaction_date) = 4 then 'Wednesday'
        when dayofweek(transaction_date) = 5 then 'Thursday'
        when dayofweek(transaction_date) = 6 then 'Friday'
        when dayofweek(transaction_date) = 7 then 'Saturday'
        else 'Sunday'
    end;


-- TO GET SALES FOR ALL HOURS FOR MONTH OF MAY
select hour(transaction_time) as Hour_of_Day, round(sum(unit_price * transaction_qty)) as Total_Sales from coffee
where month(transaction_date) = 5 -- Filter for May (month number 5)
group by hour(transaction_time)
order by hour(transaction_time);
