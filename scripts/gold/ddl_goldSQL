/*
===============================================================================
DDL Script: Create Gold Views
===============================================================================
Script Purpose:
    This script creates views for the Gold layer in the data warehouse. 
    The Gold layer represents the final dimension and fact tables.
    Each view performs transformations and combines data from the Silver layer 
    to produce a clean, enriched, and business-ready dataset.

Usage:
    - These views can be queried directly for analytics and reporting.
===============================================================================
*/

-- =============================================================================
-- Create Dimension: gold.dimension_customers
-- =============================================================================

create view gold.dimension_customers as
select 
row_number() over(order by cst_id) as Customer_key,
ci.cst_id as customer_id,
ci.cst_key as customer_number,
ci.cst_firstname as First_name,
ci.cst_lastname as Last_name,
ca.bdate as Birthday,
case when ci.cst_gndr != 'n/a' then ci.cst_gndr -- crm is the master column for gender info with right info
else coalesce (ca.gen, 'n/a')
end as Gender,
ci.cst_marital_status as Marital_status,
coalesce(la.cntry, 'n/a') as Country,
ci.cst_create_date as Create_date
from silver.crm_customer_info as ci
left join silver.erp_cust_details as ca
on ci.cst_key= ca.cid
left join silver.erp_location_details as la
on ci.cst_key = la.cid

-- =============================================================================
-- Create Dimension: gold.dimension_products
-- =============================================================================
create view gold.dimension_products as
select
row_number() over(order by pn.prd_start_dt, pn.prd_key ) as Product_key,

pn.prd_id as product_id ,
pn.prd_key as product_number,
pn.category_id,
pn.prd_name as product_name,
pc.cat as Category,
pc.subcat as Subcategory,
pn.prd_line as Product_line ,
pn.prd_cost as product_cost ,	
pc.maintenance,	
pn.prd_start_dt as Start_date 

from silver.crm_product_info as pn
left join silver.erp_product_category as pc
on pn.category_id = pc.id
where prd_end_dt is null -- filtering out all historical data

-- =============================================================================
-- Create Fact Table: gold.facts_sales
-- =============================================================================
CReate view gold.facts_sales as
select
sd.sls_ord_num as Sales_Order_number ,
pr.product_key,
cu.customer_key,
sd.sls_price as Price,
sd.sls_quantity as Quantity,	
sd.sls_sales as Sales_amount	,
sd.sls_order_dt as Sales_order_date ,	
sd.sls_ship_dt as Sales_ship_date  ,
sd.sls_due_dt as Sales_due_date 
from silver.crm_sales_details as sd
left join gold.dimension_products pr
on sd.sls_prd_key = pr.product_number
left join gold.dimension_customers as cu
on sd.sls_cust_id = cu.customer_id

-- foreign key integrity (dimensions)
select * from gold.facts_sales as f
left join gold.dimension_customers as c
on c.customer_key = f.customer_key
left join gold.dimension_products as p
on p.product_key = f.product_key
where p.product_key is null
