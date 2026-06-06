/*
===============================================================================
Cumulative Analysis
===============================================================================
Purpose:
    - To calculate running totals or moving averages for key metrics.
    - To track performance over time cumulatively.
    - Useful for growth analysis or identifying long-term trends.
===============================================================================
*/

select order_date,
total_sales,
sum(total_sales) over(partition by order_date order by order_date) as running_total_sales
from(
select 
date_trunc('month', sales_order_date) as order_date,
sum(sales_amount) as total_sales
from gold.facts_sales
where sales_order_date is not null
group by date_trunc('month', sales_order_date) 
order by date_trunc('month', sales_order_date) )
