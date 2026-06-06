/*
===============================================================================
Products Report
===============================================================================
Purpose:
    - This report consolidates key product metrics and behaviors.
Highlights:
    1. Gathers essential fields such as product name, category, subcategory, and cost.
    2. Segments products by revenue to identify High-Performers, Mid-Range, or Low-Performers.
    3. Aggregates product-level metrics:
       - total orders
       - total sales
       - total quantity sold
       - total customers (unique)
       - lifespan (in months)
    4. Calculates valuable KPIs:
       - recency (months since last sale)
       - average order revenue (AOR)
       - average monthly revenue
===============================================================================
*/
-- =============================================================================
-- Create Report: gold.report_products_data
-- =============================================================================
create view gold.report_products_data as
with base_query_products as (
-- 1. Base query: Retrieves core columns from tables
select 
f.customer_key,
p.product_key,
p.product_name,
p.category,
p.subcategory,
p.product_cost,
f.sales_order_number,
f.sales_amount,
f.quantity,
f.sales_order_date
from gold.facts_sales as f
left join gold.dimension_products as p
on p.product_key = f.product_key
where sales_order_date is not null
)

, product_aggregation as (
-- 2. Product Aggregations: Summarizes key metrics at the customer level
select 
product_key,
product_name,
category,
subcategory,
product_cost,
extract(year from age (max(sales_order_date) , min(sales_order_date))) *12 +
extract(month from age (max(sales_order_date) , min(sales_order_date))) as lifespan,
count(distinct sales_order_number) as total_orders,
sum(sales_amount) as total_sales,
sum(quantity) as total_quantity_sold,
count(distinct customer_key) as total_customers,
max(sales_order_date) as last_sales_date,
round(avg(sales_amount/nullif(quantity,0)), 1) as avg_selling_price
from base_query_products
group by product_key,
product_name,
category,
subcategory,
product_cost
)

-- 3. final query - combine all product result into one output
select
product_key,
product_name,
category,
subcategory,
product_cost,
case when total_sales >= 800000 then 'High Performer'
 when total_sales >= 400000  then 'Mid Performer'
else 'Low Performer'
end  as product_segmentation,
lifespan,
total_orders,
total_sales,
total_quantity_sold,
total_customers,
last_sales_date,
avg_selling_price,
extract(year from age (current_date, last_sales_date )) *12 +
extract(month from age (current_date, last_sales_date)) as recency_in_months,
-- compute average order revenue
case when total_orders = 0 then 0
else total_sales/ total_orders 
end as average_order_revenue,
-- average monthly revenue
case when lifespan = 0 then total_sales
else total_sales/lifespan
end as avg_monthly_revenue
from product_aggregation
