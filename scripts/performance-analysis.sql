/*
===============================================================================
Performance Analysis (Year-over-Year, Month-over-Month)
===============================================================================
Purpose:
    - To measure the performance of products, customers, or regions over time.
    - For benchmarking and identifying high-performing entities.
    - To track yearly trends and growth.
SQL Functions Used:
    - LAG(): Accesses data from previous rows.
    - AVG() OVER(): Computes average values within partitions.
    - CASE: Defines conditional logic for trend analysis.
===============================================================================
*/


with yearly_products_sales as 
select p.product_name,
extract(year from f.sales_order_date) as order_year,
sum(f.sales_amount) as current_sales
from gold.facts_sales as f
left join gold.dimension_products as p
on p.product_key = f.product_key
where sales_order_date is not null
group by p.product_name,extract(year from f.sales_order_date) 
)

select order_year,
product_name,
current_sales,
avg(current_sales)over(partition by product_name) as avg_sales,
current_sales-avg(current_sales)over(partition by product_name) as diff_avg,
case when current_sales-avg(current_sales)over(partition by product_name) > 0 then 'Above avg'
when current_sales-avg(current_sales)over(partition by product_name) < 0 then 'Below avg'
else 'Avg'
end Avg_change ,
lag(current_sales) over(partition by product_name order by order_year) as previous_year_sales,
current_sales-lag(current_sales) over(partition by product_name order by order_year) as yearly_difference_sales,
case when current_sales-lag(current_sales) over(partition by product_name order by order_year) > 0 then 'Increasing'
when current_sales-lag(current_sales) over(partition by product_name order by order_year) < 0 then 'Decreasing'
else 'No Change'
end Yearly_performance_analysis 
from yearly_products_sales
