/*
===============================================================================
Change Over Time Analysis
===============================================================================
Purpose:
    - To track trends, growth, and changes in key metrics over time.
    - For time-series analysis and identifying seasonality.
    - To measure growth or decline over specific periods.
===============================================================================
*/

select 
extract(year from sales_order_date) as order_year,
extract(month from sales_order_date) as order_month,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.facts_sales
where sales_order_date is not null
group by extract(year from sales_order_date),extract(month from sales_order_date) 
order by extract(year from sales_order_date),extract(month from sales_order_date) 

select 
date_trunc('month', sales_order_date) as order_date,
sum(sales_amount) as total_sales,
count(distinct customer_key) as total_customers,
sum(quantity) as total_quantity
from gold.facts_sales
where sales_order_date is not null
group by date_trunc('month', sales_order_date) 
order by date_trunc('month', sales_order_date) 
