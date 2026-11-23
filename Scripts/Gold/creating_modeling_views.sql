
--Creating Tableview Dim_customers:
IF NOT EXISTS (SELECT * FROM sys.schemas WHERE name = 'gold')
    EXEC('CREATE SCHEMA gold');
GO

CREATE OR ALTER VIEW gold.dim_customers AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY ci.cst_id) AS customer_rk,
    ci.cst_id AS customer_id,
    ci.cst_key AS customer_key,
    ci.cst_firstname AS firstname,
    ci.cst_lastname AS lastname,
    CASE 
        WHEN ci.cst_gndr = 'N/A' THEN COALESCE(az.GEN, 'N/A')
        ELSE ci.cst_gndr 
    END AS gender,
    ci.cst_marital_status AS martial_status,
    COALESCE(az.BDATE, '1900-01-01') AS birthdate,
    COALESCE(loc.CNTRY, 'N/A') AS country,
    ci.cst_create_date AS creation_date
FROM silver.crm_cust_info ci
LEFT JOIN silver.erp_cust_az12 az ON ci.cst_key = az.CID
LEFT JOIN silver.erp_loc_a101 loc ON ci.cst_key = loc.CID;
GO
SELECT TOP 10 * FROM gold.dim_customers;
SELECT TOP 10 * FROM silver.crm_cust_info
SELECT TOP 10 * FROM silver.erp_loc_a101
SELECT TOP 10 * FROM silver.erp_cust_az12
-- now we will creat Dim_Product :
CREATE OR ALTER VIEW gold.dim_products AS
SELECT 
    ROW_NUMBER() OVER (ORDER BY pi.prd_start_dt, pi.prd_id) AS product_sk,
    pi.prd_id AS product_id,
    pi.prd_key AS prdky,
    pi.prd_nm AS product_name,
    pi.cat_id AS product_key,
    pc.CAT AS category,
    pc.SUBCAT AS subcategory,
    pc.MAINTENANCE AS maintenance,
    pi.prd_cost AS cost,
    pi.prd_line AS line,
    pi.prd_start_dt AS start_dat,
    pi.prd_end_dt AS end_dt
FROM silver.crm_prd_info pi
LEFT JOIN silver.erp_px_cat_g1v2 pc ON pi.cat_id = pc.ID;
SELECT TOP 10 * FROM silver.crm_prd_info
SELECT TOP 10 * FROM silver.erp_px_cat_g1v2
SELECT top 10 * FROM gold.dim_products
--Now we create Fact_Sales:
CREATE OR ALTER VIEW gold.fact_sales AS
SELECT 
    sd.sls_ord_num AS order_number,
    dp.product_sk,
    dc.customer_rk,
    sd.sls_order_dt AS order_date,
    sd.sls_ship_dt AS ship_date,
    sd.sls_due_dt AS due_date,
    sd.sls_sales AS sales_amount,
    sd.sls_quantity AS quantity,
    sd.sls_price AS price
FROM silver.crm_sales_details sd
LEFT JOIN gold.dim_products dp ON sd.sls_prd_key = dp.prdky
LEFT JOIN gold.dim_customers dc ON sd.sls_cust_id = dc.customer_id;
SELECT TOP 10 * FROM gold.fact_sales
--
SELECT TOP 10 * FROM silver.crm_sales_details
SELECT TOP 10 * FROM silver.crm_prd_info
SELECT TOP 10 * FROM silver.crm_cust_info
