-- Creating a table Name Sales_transaction

create table Sales_transactions(
invoice_id varchar(30) primary key,
branch varchar(20) not null,
city varchar(30) not null,
customer_type varchar(30) not null,
gender varchar(15) not null,
product_line varchar(100) not null,
unit_price decimal(10,2) not null,
quantity int not null,
vat decimal(10,4) not null,
total decimal(10,2) not null,
Dates date not null ,
Purchase_time time not null,
payment_method varchar(20) not null,
cogs decimal(10,2) not null,
gross_margin_percentage decimal(11,9) not null,
gross_income decimal(10,2) not null,
rating decimal(3,1)

);

use amazon;
describe sales_transactions;

select * from sales_transactions;
-- to check the right amount of rows matching the dataset
select count(*) from sales_transactions;

-- adding a new column timeofday 
alter table sales_transactions
add column timeofday varchar (20) not null;

set sql_safe_updates = 0;
 
update sales_transactions
set timeofday = 
				case 
                when hour(purchase_time) >= 0 and hour(purchase_time) < 12 then 'Morning'
                when hour(purchase_time) >= 12 and hour(purchase_time) < 18 then 'Afternoon'
                else 
                     'Evening'
				end ;

# adding day name column
alter table sales_transactions
add column day_name varchar (20) not null;

update sales_transactions 
set day_name = dayname(dates);

# adding month column 
alter table sales_transactions
add column month_name varchar (20);

update sales_transactions 
set month_name = monthname(dates);

# 1) count of different cities 
select city,count(distinct city) as distinct_city from sales_transactions
group by city;

# 2) branch = city 
select distinct(branch) as distinct_branch,city  from sales_transactions
order by branch;

# 3) count of distinct products 
select product_line,count(distinct product_line) as product_line 
from sales_transactions
group by product_line;

# 4) most frequent payment method 
select payment_method,count(*) as most_frequent 
from sales_transactions
group by payment_method 
order by most_frequent desc
limit 1;

# 5) product line high sales 
select product_line, sum(total) as highest_sale 
from sales_transactions 
group by 1 
order by 1 desc
limit 1;

# 6) revenue per month 
select month_name,sum(gross_income) as profit 
from sales_transactions 
group by month_name 
order by min(month(dates)) asc;

# 7) month of peak cogs 
select month_name,sum(cogs) as peak_cogs 
from sales_transactions
group by 1
order by max(cogs)
limit 1;

# 8) product line highest revenue 
select product_line,sum(gross_income) as revenue 
from sales_transactions
group by product_line 
order by sum(gross_income) desc
limit 1;

# 9) city highest revenue 
select city,sum(gross_income) as revenue 
from sales_transactions
group by 1 
order by 2 desc 
limit 1;

# 10) product line highest vat 
select product_line,sum(vat) as vat 
from sales_transactions 
group by 1 
order by 2 desc
limit 1;

# 11) product line add column with good and bad 
alter table sales_transactions
add column product_performance_indicator varchar(15);
        
create temporary table product_line_summary as 
select product_line,sum(total) as total_sales 
from sales_transactions
group by 1;
                                                        
select avg(total_sales) into @avg_sales
from product_line_summary;

                                                        
update sales_transactions st 
join product_line_summary pls on 
st.product_line = pls.product_line
set st.product_performance_indicator = 
                                      case
                                           when pls.total_sales > @avg_sales then 'Good'
                                           else 'Bad'
                                           end;
									
                                    
select * from sales_transactions;                                    
# 12) branch greater than avg products sold                                     
select branch,sum(quantity) as quantity_sold 
from sales_transactions
group by 1
having sum(quantity) > 
					  (select avg(total_units_sold) from 
                        (select sum(quantity) as total_units_sold
                        from sales_transactions 
                        group by branch) as branch_units_sold
                        );
                        

# 13) most frequently orders by gender 
select gender,product_line,productline_count
from (select gender,product_line,count(*) as productline_count,
		dense_rank() over(partition by gender order by count(*) desc) as ranks 
        from sales_transactions
        group by 1,2
        ) as ranked_temp_table 
        where ranks = 1;
        
# 14) avg rating for each product line 
select product_line,avg(rating) as avg_rating 
from sales_transactions 
group by 1
order by avg(rating) desc;

# 15) count sales for each time of day & weekday

# select * from sales_transactions;					
select day_name,timeofday,count(*) as sales_occured
from sales_transactions 
where day_name in ('Monday','Tuesday','Wednesday','Thursday','Friday')
group by 1,2 
order by 
		case day_name 
			when 'Monday' then 1
            when 'Tuesday' then 2 
            when 'Wednesday' then 3
            when 'Thursday' then 4
            when 'Friday' then 5 
		end,
        case timeofday
			when 'Morning' then 1 
            when 'Afternoon' then 2 
            when 'Evening' then 3
		end;
        
# 16) customer type highest contribution in sales 
select customer_type,sum(total) as sales 
from sales_transactions 
group by 1 
order by sales desc
limit 1 ;

# 17) city with highest vat 
select * from sales_transactions;

select city,sum(vat) as highest_vat,
(sum(vat) * 100/(select sum(vat) from sales_transactions)) as Vat_percent
from sales_transactions 
group by 1
order by highest_vat desc
limit 1;

# 18) customer type with highest vat 
select customer_type,sum(vat) as highest_vat,
(sum(vat) * 100/(select sum(vat) from sales_transactions)) as vat_percent
from sales_transactions 
group by 1
order by vat_percent desc
limit 1;

# 19) count of distinct customer type
select count(distinct customer_type) as distinct_customer 
from sales_transactions;

# 20) count of distinct payment methods 
select count(distinct payment_method) as paymentmethod 
from sales_transactions;

# 21) customer type occur most frequently 
select customer_type,count(*) as customer_count
from sales_transactions 
group by 1
order by count(*) desc
limit 1;

# 22) customer type with highest frequency purchase 
select customer_type,count(distinct invoice_id) as purchase_frequency
from sales_transactions 
group by 1
order by 2 desc
limit 1;

# 23) most predominant gender 
select gender,count(*) as gender_count
from sales_transactions 
group by 1 
order by gender_count desc
limit 1;

select gender,sum(total) as sales 
from sales_transactions 
group by 1 
order by sales desc;

# 24) the distribution of genders within each branch
select branch,gender,count(*) as gender_count 
from sales_transactions 
group by 1,2
order by 1,2 desc;

# 25 the time of day when customers provide the most ratings
select timeofday,count(rating) as most_Rating 
from sales_transactions 
where rating is not null
group by 1
order by most_rating desc
limit 1;

# 26) the time of day with the highest customer ratings for each branch 
select branch,city,timeofday,count(rating) as ratings 
from sales_Transactions
group by 1,2,3
order by ratings desc;

# 27) the day of the week with the highest average ratings.
select day_name,avg(rating) as avg_Rating 
from sales_transactions 
group by 1
order by 2 desc
limit 1;

# 28) the day of the week with the highest average ratings for each branch.
select branch,day_name,avg(Rating) as ratings 
from sales_transactions 
group by 2,1
order by ratings desc
limit 1 ;

