/*
===============================================================================
Data Segmentation Analysis
===============================================================================
Purpose:
    - To group data into meaningful categories for targeted insights.
    - For customer segmentation, product categorization, or regional analysis.

SQL Functions Used:
    - CASE: Defines custom segmentation logic.
    - GROUP BY: Groups data into segments.
===============================================================================
*/

/*Segment products into cost ranges and 
count how many products fall into each segment*/

with product_segments as(
select product_key,
product_name,
product_cost,
case when product_cost < 100 then 'below 100'
when product_cost between 100 and 500 then '100-500'
when product_cost between 500 and 1000 then '500-1000'
else 'above 1000'
end cost_range
from gold.dimension_products
)
select
cost_range,
count(product_key) as total_products
from product_segments
group by cost_range
order by total_products desc

-- group customers into the three segments based on their spending behavior
-- vip: customers with atleast 12 months of history and spending more than $5000
-- regular : customers with atleast 12 months of history and spending more than $5000 or less
-- new : customers with lifespan less than 12 months 
--and find total number of customers by each group


with customer_spending as(
select
c. customer_key,
sum(f.sales_amount) as total_spending,
min(sales_order_date) as first_order,
max(sales_order_date) as last_order,
(extract(year from age (max(sales_order_date) , min(sales_order_date))) *12 +
extract(month from age (max(sales_order_date) , min(sales_order_date)))) as lifespan
from gold.facts_sales as f
left join gold.dimension_customers as c
on c.customer_key = f.customer_key
group by c.customer_key)

select customer_segmentation,
count(customer_key) as total_customers
from(
select customer_key,
total_spending,
lifespan,
case when lifespan >= 12 and total_spending > 5000 then 'VIP'
when lifespan >= 12 and total_spending <= 5000 then 'Regular'
else 'New'
end customer_segmentation
from customer_spending)
group by customer_segmentation
order by total_customers
