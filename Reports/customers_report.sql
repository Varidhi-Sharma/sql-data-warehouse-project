/*
===============================================================================
Customers Report
===============================================================================
Purpose:
    - This report consolidates key customers metrics and behaviors
Highlights:
    1. Gathers essential fields such as names, ages, and transaction details.
	2. Segments customers into categories (VIP, Regular, New) and age groups.
    3. Aggregates customer-level metrics:
	   - total orders
	   - total sales
	   - total quantity purchased
	   - total products
	   - lifespan (in months)
    4. Calculates valuable KPIs:
	    - recency (months since last order)
		- average order value
		- average monthly spend
===============================================================================
*/

-- =============================================================================
-- Create Report: gold.report_customers_data
-- =============================================================================
create view gold.report_customers_data as
with base_query as (
-- 1. Base query: Retrieves core columns from tables
select 
f.product_key,
c.customer_key,
c.customer_number,
f.sales_order_number,
concat(c.first_name, ' ',c.last_name) as customer_name,
extract(year from age(c.birthday)) as customer_age,
f.sales_amount,
f.quantity,
f.sales_order_date
from gold.facts_sales as f
left join gold.dimension_customers as c
on c.customer_key = f.customer_key
where sales_order_date is not null
)

,customer_aggregation as(
-- 2. Customer Aggregations: Summarizes key metrics at the customer level
select 
customer_key,
customer_number,
customer_name,
customer_age,
count(distinct sales_order_number) as total_orders,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity,
count(distinct product_key) as total_products,
max(sales_order_date) as last_order_date,
extract(year from age (max(sales_order_date) , min(sales_order_date))) *12 +
extract(month from age (max(sales_order_date) , min(sales_order_date))) as customer_membership_lifespan
from base_query
group by 
customer_key,
customer_number,
customer_name,
customer_age)

select
customer_key,
customer_number,
customer_name,
customer_age ,
case when customer_age < 20 then 'Under 20'
when customer_age between 20 and 29 then '20-29'
when customer_age between 30 and 39 then '30-39'
when customer_age between 40 and 49 then '40-49'
else '50 and above'
end as age_group,
customer_membership_lifespan,
case when customer_membership_lifespan >= 12 and total_sales > 5000 then 'VIP'
when customer_membership_lifespan >= 12 and total_sales <= 5000 then 'Regular'
else 'New'
end  as customer_segmentation,
total_orders,
total_sales,
total_quantity,
total_products,
last_order_date,
extract(year from age (current_date, last_order_date )) *12 +
extract(month from age (current_date, last_order_date)) as recency,
-- compute average order value
case when total_sales = 0 then 0
else total_sales/ total_orders 
end as average_order_value,
-- average monthly spend
case when customer_membership_lifespan = 0 then total_sales
else total_sales/customer_membership_lifespan
end as customer_avg_monthly_spend
from customer_aggregation
