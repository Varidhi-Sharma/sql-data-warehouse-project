/*
===============================================================================
DDL Script: Create Silver Tables
===============================================================================
Script Purpose:
    This script creates tables in the 'silver' schema, dropping existing tables 
    if they already exist.
===============================================================================
*/

create table silver.crm_customer_info(
cst_id int,
cst_key varchar (50),
cst_firstname varchar (50),
cst_lastname varchar (50),
cst_material_status varchar (50),
cst_gndr varchar (50),
cst_create_date date 
)

create table silver.crm_product_info(
prd_id int,
prd_key	varchar (50),
prd_name varchar (50),	
prd_cost int,	
prd_line varchar (50),	
prd_start_dt date,	
prd_end_dt date)


/*  dropped the table and recreated it,
 to change the data type of date from varchar to date*/
Drop table silver.crm_sales_details
create table silver.crm_sales_details(
sls_ord_num	varchar (50),
sls_prd_key	varchar (50),
sls_cust_id	int,
sls_order_dt date ,	
sls_ship_dt date ,
sls_due_dt date,
sls_sales	int,
sls_quantity int,	
sls_price int
)
create table silver.erp_cust_details(
CID	varchar (50),
BDATE date,	
GEN varchar (50)
)
create table silver.erp_location_details(
CID	varchar (50),
CNTRY varchar (50)
)
create table silver.erp_product_category(
ID	varchar (50),
CAT	varchar (50),
SUBCAT	varchar (50),
MAINTENANCE varchar (50)
)
update bronze.crm_product_info
set prd_cost = coalesce(prd_cost,0)
where prd_cost is null

