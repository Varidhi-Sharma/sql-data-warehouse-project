/*
===============================================================================
Stored Procedure: Load Silver Layer (Bronze -> Silver)
===============================================================================
Script Purpose:
    This stored procedure performs the ETL (Extract, Transform, Load) process to 
    populate the 'silver' schema tables from the 'bronze' schema.
	Actions Performed:
		- Truncates Silver tables.
		- Inserts transformed and cleansed data from Bronze into Silver tables.
===============================================================================
*/
create or replace procedure silver.load_silver()
language plpgsql
as $$
begin

truncate table silver.crm_customer_info;
insert into silver.crm_customer_info(
cst_id ,
cst_key ,
cst_firstname, 
cst_lastname ,
cst_marital_status,
cst_gndr ,
cst_create_date)

Select
cst_id ,
cst_key ,
trim (cst_firstname) as cst_firstname ,
trim (cst_lastname) as cst_lastname ,
case when upper(trim(cst_marital_status)) = 'M' then 'married' 
when upper(trim(cst_marital_status)) = 'S' then 'Single'
else 'n/a'
end cst_marital_status,
case when upper(trim(cst_gndr)) = 'F' then 'Female'
when upper(trim(cst_gndr)) = 'M' then 'Male'
else 'n/a'
end cst_gndr,
cst_create_date
from (

select * from ( select *,
Row_number() over(partition by cst_id order by cst_create_date desc) as flag_last
from bronze.crm_customer_info) )
where flag_last =1 ;



/* for  silver.crm_product_info*/

truncate table silver.crm_product_info;
insert into silver.crm_product_info(
prd_id,
category_id,
prd_key,
prd_name,	
prd_cost,	
prd_line,	
prd_start_dt,	
prd_end_dt
)
select prd_id ,
replace(substring (prd_key, 1, 5), '-', '_' ) as category_id,
substring(prd_key, 7, length(prd_key)) as prd_key,
prd_name ,	
prd_cost ,
case when upper(trim(prd_line)) = 'M' then 'Mountain'
when upper(trim(prd_line)) = 'R' then 'Road'
when upper(trim(prd_line)) = 'S' then 'Other Sales'
when upper(trim(prd_line)) = 'T' then 'Touring'
else 'n/a'
end prd_line,
prd_start_dt,
lead(prd_start_dt ) over(partition by prd_key order by prd_start_dt)-1 as prd_end_dt
from bronze.crm_product_info;



/* for  silver.crm_sales_details*/

truncate table silver.crm_sales_details;
insert into silver.crm_sales_details(
sls_ord_num	,
sls_prd_key	,
sls_cust_id	,
sls_order_dt  ,	
sls_ship_dt  ,
sls_due_dt ,
sls_sales	,
sls_quantity ,	
sls_price)

select 
sls_ord_num	,
sls_prd_key	,
sls_cust_id	,	
case when (sls_order_dt) = '0' or length (sls_order_dt) != 8 then null
else cast (cast(sls_order_dt as varchar) as date)
end sls_order_dt,
case when (sls_ship_dt) = '0' or length (sls_ship_dt) != 8 then null
else cast (cast(sls_ship_dt as varchar) as date)
end sls_ship_dt,
case when sls_due_dt = '0' or length (sls_due_dt) != 8 then null
else cast (cast(sls_due_dt as varchar) as date)
end sls_due_dt,
case when sls_sales is null or sls_sales <= '0 'or sls_sales != sls_quantity * abs(sls_price)
then sls_quantity * abs(sls_price)
else sls_sales
end sls_sales,
sls_quantity ,	
case when sls_price is null or sls_price <= '0 '
then sls_sales /nullif(sls_quantity,0)
else sls_price
end sls_price
from bronze.crm_sales_details;

/* for  silver.erp_cust_details*/

truncate table silver.erp_cust_details;
insert into silver.erp_cust_details(
CID	,
BDATE,	
GEN
)
select
case when cid like 'NAS%' then substring(cid, 4, length(cid))
else cid
end cid,
case when BDATE> current_date then null
else bdate
end bdate,	
case  when  upper(trim(GEN )) in ( 'F', 'FEMALE') then 'Female'
when  upper(trim(GEN )) in ( 'M', 'MALE') then 'Male'
else 'n/a'
end Gen 
from bronze.erp_cust_details;

/* for silver.erp_location_details*/

truncate table silver.erp_location_details;
insert into silver.erp_location_details(cid, cntry)
select
replace(cid,'-', '')cid,
case when trim(CNTRY) = 'DE' then 'Germany'
when trim(CNTRY) in ('US', 'USA') then 'United States'
when trim(CNTRY) = '' or cntry is null  then 'n/a'
else trim(CNTRY) 
end cntry
from bronze.erp_location_details;

/*for silver.erp_product_category*/


truncate table silver.erp_product_category;
insert into silver.erp_product_category(ID,
CAT	,
SUBCAT ,
MAINTENANCE)

select ID,
CAT	,
SUBCAT ,
MAINTENANCE
from bronze.erp_product_category;
end
$$

/*to execute stored procedure*/

select routine_definition
from information_schema.routines
where routine_schema = 'silver'
and routine_name ='load_silver'
