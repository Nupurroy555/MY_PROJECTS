-- ......Creating database called "Amazon"
create database Amazon;

-- ......use amazon database
use amazon;

-- .....importing table by using "table data import wizard"
select * from sales;
/* data imported successfully

After observing the columns,those column names and data types are different in imported data to original data
1,changing the column names to original
2,changing datatypes of columns in the sales table to original datatypes

1.changing column names to original
'Invoice ID' to invoice_id
'Customer type' to Customer_type
'Product line' to Product_line
'Unit price' to Unit_price
'Tax 5%' to VAT
'Payment' to Payment_method
'gross margin percentage' to gross_margin_percentage
'gross income' to gross_income
*/

ALTER TABLE sales CHANGE COLUMN `Invoice ID` invoice_id text;
ALTER TABLE sales CHANGE COLUMN `Customer type` Customer_type text;
ALTER TABLE sales CHANGE COLUMN `Product line` Product_line text;
ALTER TABLE sales CHANGE COLUMN `Unit price` Unit_price double;
ALTER TABLE sales CHANGE COLUMN `Tax 5%` VAT double;
ALTER TABLE sales CHANGE COLUMN `Payment` Payment_method text;
ALTER TABLE sales CHANGE COLUMN `gross margin percentage` gross_margin_percentage double;

/* 2,changing datatypes of columns in the sales table to original datatypes

invoice_id to VARCHAR(30)
branch to VARCHAR(5)
City to VARCHAR(30)
Customer_type to VARCHAR(30)
Gender to VARCHAR(10)
Product_line to VARCHAR(100)
Unit_Price to Decimal(10,2)
VAT to FLOAT(6,4)
total to DECIMAL(10,2)
date to DATE
time to TIME
payment_method to DECIMAL(10,2)
cogs to DECIMAL(10,2)
Gross_margin_percentage to Float(11,9)
gross_income to DECIMAL(10,2)
rating to Float(2,1)
*/

ALTER TABLE sales MODIFY COLUMN invoice_id VARCHAR(30);
ALTER TABLE sales MODIFY COLUMN Branch VARCHAR(30);
ALTER TABLE sales MODIFY COLUMN City VARCHAR(30);
ALTER TABLE sales MODIFY COLUMN Customer_type VARCHAR(30);
ALTER TABLE sales MODIFY COLUMN Gender VARCHAR(10);
ALTER TABLE sales MODIFY COLUMN Product_line VARCHAR(100);
ALTER TABLE sales MODIFY COLUMN Unit_Price DECIMAL(10,2);
ALTER TABLE sales MODIFY COLUMN VAT FLOAT (6);
ALTER TABLE sales MODIFY COLUMN Total DECIMAL(10,2);
ALTER TABLE sales MODIFY COLUMN Date DATE;
ALTER TABLE sales MODIFY COLUMN Time Time;
ALTER TABLE sales MODIFY COLUMN Payment_method VARCHAR(100);
ALTER TABLE sales MODIFY COLUMN cogs DECIMAL (10,2);
ALTER TABLE sales MODIFY COLUMN gross_margin_percentage FLOAT(11);
ALTER TABLE sales MODIFY COLUMN gross_income DECIMAL(10,2);
ALTER TABLE sales MODIFY COLUMN rating double;

-- ..............................................
-- .... after modifications, table look like below

select * from sales;

-- ........ checking null values 
select * from sales
where invoice_id is null or
Branch is null or
City is null or
Customer_type is null or
gender is null or
Product_line is null or
Unit_price is null or
Quantity is null or
VAT is null or
Total is null or
Date is null or
Time is null or 
Payment_method is null or
cogs is null or
gross_margin_percentage is null or
gross_income is null or
rating is null;

/*.....no null value present in table*/
-- .......=====================================
-- ..........==================================
-- .......Feature Engineering..........

-- .....1,Adding a new column named time of day
ALTER TABLE sales
ADD COLUMN timeofday VARCHAR(15);

SET SQL_SAFE_UPDATES=0;

UPDATE sales  
SET timeofday =  
    CASE   
        WHEN HOUR(Time) < 12 THEN 'Morning'         
        WHEN HOUR(Time) < 18 THEN 'Afternoon'         
        ELSE 'Evening'  
    END;
-- .................................

-- ....2,Adding a new column named dayname

ALTER TABLE sales
ADD COLUMN dayname VARCHAR(10);

UPDATE sales
SET dayname = DAYNAME(date);

-- ..........................................
-- .....3,Adding a new column named monthname

ALTER TABLE sales 
ADD COLUMN monthname VARCHAR(20);

UPDATE sales
SET monthname = MONTHNAME(date);

-- ........========================
-- ...........=====================

-- -----Analysis list
-- ....1,Product Analysis 2,Sales Analysis

select Product_line, count(*)as transaction_count,avg(quantity) as avg_quantity_sold_per_transaction,
sum(quantity) as total_quantity_sold,avg(unit_price) as average_unit_price,sum(total) as total_sales_revenue,
sum(gross_income) as total_gross_income,(sum(gross_income)/sum(total))*100 as gross_margin_percentage
from sales
group by product_line
order by total_sales_revenue desc;
-- .......conclusions
-- 1.(based on product analysis)

-- Top performers: Fashion acessories,Food and beverages
-- Under performers:Home and lifestyle,Health and beauty

-- ..2.(based on sales analysis)

-- Top performers:Food and beverages,Sports and travel are performing relatively well in terms of total sales revenue and total gross income
-- under performers:Health and beauty have lower total sales revenue and gross income compared to other product lines		

-- Actions to take:
-- Adjusting pricing strategies for underperformig product lines
-- increasing targeted marketing campaigns or promotions to increase visibility and demand for lower performing product lines
-- with fashion accessories ,recommending health and beauty products will increase the sales

-- ....3,customer analysis
WITH gender_spending as(select gender,product_line,count(*) as no_of_purchase,sum(total) as total_spending,round(avg(rating),2)
as avg_rating
from sales
group by gender,product_line)

select product_line,sum(case when gender='male' then no_of_purchase else 0 end) as male_no_of_purchase,
sum(case when gender='female' then no_of_purchase else 0 end )as female_no_of_purchase,sum(case when gender='male'
then total_spending else 0 end )as male_spending,sum(case when gender='female'then total_spending else 0 end )as female_spending,
sum(case when gender='male' then avg_rating else 0 end)as male_avg_rating,sum(case when gender='female' then avg_rating else
0 end)as female_avg_rating
from gender_spending
group by product_line
order by male_spending desc;

-- ....conclusions.......
-- .......males are more spending on health and beauty,electronic accessories but rating of those product_lines 
-- are less,we have to increase quality
-- ....female are more spending on food bevereges,fashion acessories,rating also high for these product_line
-- =========================================================================================================================

 --  .....Business questions to answer............

-- 1.What is the count of distinct cities in the dataset?
select DISTINCT City from sales;

-- 2.For each branch, what is the corresponding city?
select DISTINCT branch ,city from sales;

-- 3.What is the count of distinct product lines in the dataset?
select count(distinct product_line) from sales;

-- 4.Which payment method occurs most frequently?
select payment_method,count(payment_method)as cnt
from sales
group by payment_method
order by cnt desc
limit 1;

-- 5.Which product line has the highest sales?
select product_line,count(product_line) as cnt_of_sales
from sales
group by product_line
order by cnt_of_sales desc
limit 1;

-- 6.How much revenue is generated each month?
select monthname as month,round(sum(total),2) as revenue
from sales
group by month
order by revenue desc;

-- 7.In which month did the cost of goods sold reach its peak?
select monthname as month,sum(cogs)as total_cogs
from sales 
group by month
order by total_cogs desc
limit 1;

-- 8.Which product line generated the highest revenue?
select product_line,round(sum(total),2) as revenue
from sales
group by product_line
order by revenue desc
limit 1;

-- 9.In which city was the highest revenue recorded?
select city,round(sum(total),2) as revenue
from sales
group by city
order by revenue desc
limit 1;

-- 10.Which product line incurred the highest Value Added Tax?
select product_line,round(sum(VAT),2)as total_vat
from sales 
group by product_line
order by total_vat desc
limit 1;

-- 11.For each product line, add a column indicating "Good" if its sales are above average, otherwise "Bad."
select * from sales;
select product_line,
(case
 when sum(total) > (select avg(total)from sales) then "Good" else "Bad" end) as sales_status
 from sales 
 group by product_line;

-- 12.Identify the branch that exceeded the average number of products sold
select branch,sum(quantity)as qty
from sales
group by branch
having sum(quantity)>(select avg(quantity) from sales)
order by qty desc
limit 1;
        
-- 13.Which product line is most frequently associated with each gender?
WITH gender_spending as(select gender,product_line,count(*) as no_of_purchase from sales
group by gender,product_line)

select product_line,
sum(case when gender='male' then no_of_purchase else 0 end)as male_frequency,
sum(case when gender='female' then no_of_purchase else 0 end) as female_frequency
from gender_spending
group by product_line
order by male_frequency desc;

-- 14.Calculate the average rating for each product line.
select product_line,round(avg(rating),2) as avg_rating
from sales
group by product_line;

-- 15.Count the sales occurrences for each time of day on every weekday.
select timeofday,count(*) as sales_occurences
from sales
group by timeofday
order by sales_occurences desc;

-- 16.Identify the customer type contributing the highest revenue.
select customer_type,sum(total) as total_revenue
from sales
group by customer_type
order by total_revenue desc
limit 1;
        
-- 17.Determine the city with the highest VAT percentage.
select city,sum(VAT)/sum(total)*100 as vatt
from sales
group by city
order by vatt desc
limit 1;
        
-- 18.Identify the customer type with the highest VAT payments
select customer_type,vat 
from sales
group by customer_type,vat
order by vat desc
limit 1;

-- 19.What is the count of distinct customer types in the dataset?
select count(distinct customer_type)
from sales;

-- 20.What is the count of distinct payment methods in the dataset?
select count(distinct payment_method) from sales

-- 21.Which customer type occurs most frequently?
SELECT 
    Customer_type, 
    COUNT(*) AS frequency 
FROM 
    sales 
GROUP BY 
    Customer_type 
ORDER BY 
    frequency DESC 
LIMIT 1;

-- 22.Identify the customer type with the highest purchase frequency.
select Customer_type,count(*) as purchase_frequency from sales
group by customer_type
order by purchase_frequency 
limit 1;

-- 23.Determine the predominant gender among customers.
select gender,count(*) as frequency
from sales
group by gender
order by frequency desc
limit 1;

-- 24.Examine the distribution of genders within each branch.
select branch,gender,count(*) as frequency 
from sales
group by branch,gender
order by fequency;

-- 25.Identify the time of day when customers provide the most ratings
select timeofday,count(rating) as freuency
from sales
group by timeofday;

-- 26.Determine the time of day with the highest customer ratings for each branch.
SELECT dayname, timeofday, branch, count(rating) as frequency 
FROM sales 
GROUP BY dayname, timeofday, branch 
ORDER BY frequency DESC 
LIMIT 0, 1000;

-- 27.Identify the day of the week with the highest average ratings.
select dayname,avg(rating) as avg_rating
from sales
group by dayname
order by avg_rating desc
limit 1;

-- 28.Determine the day of the week with the highest average ratings for each branch
SELECT dayname, branch, AVG(rating) AS avg_rating 
FROM sales 
GROUP BY dayname, branch 
ORDER BY branch, avg_rating DESC 
LIMIT 0, 1000;
