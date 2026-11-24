/* ============================================================
   Stored Procedure: silver.usp_importing_slvr
   ------------------------------------------------------------
   1. Main transformation & load proc: reads from bronze, applies
      all cleaning rules, and loads the cleaned data into silver.
   2. Per table: TRUNCATE silver → run cleaning CTE → INSERT SELECT,
      so every run does a full refresh (idempotent, re-runnable).
   3. Cleaning rules: trim strings, standardize coded values
      (marital status, gender, product line, country, IDs),
      dedupe customers (ROW_NUMBER by latest create_date), fix
      dates, recalc inconsistent sales/price, derive prd_end_dt.
   4. Runs all 6 CRM/ERP tables in sequence — bronze must already
      be loaded (run bronze.usp_Load_Bronze_Tables first).
   5. Ends with EXEC + sample SELECTs to verify each silver table.
   ============================================================ */
--Create procedure for loading table after transformations 
CREATE OR ALTER PROCEDURE silver.usp_importing_slvr
AS
BEGIN
    SET NOCOUNT ON;

    -- 1. Clean & Load crm_cust_info
    TRUNCATE TABLE silver.crm_cust_info;
    WITH cte_crm AS (
        SELECT
            cst_id,
            cst_key,
            TRIM(cst_firstname) AS cst_firstname,
            TRIM(cst_lastname) AS cst_lastname,
            CASE UPPER(TRIM(cst_marital_status)) 
                WHEN 'M' THEN 'Married'
                WHEN 'S' THEN 'Single'
                ELSE 'N/A'
            END AS cst_marital_status,
            CASE UPPER(TRIM(cst_gndr)) 
                WHEN 'M' THEN 'Male'
                WHEN 'F' THEN 'Female'
                ELSE 'N/A'
            END AS cst_gndr,
            cst_create_date,
            ROW_NUMBER() OVER (
                PARTITION BY cst_id
                ORDER BY cst_create_date DESC
            ) AS rn
        FROM bronze.crm_cust_info
        WHERE cst_id IS NOT NULL
    )
    INSERT INTO silver.crm_cust_info (cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date)
    SELECT cst_id, cst_key, cst_firstname, cst_lastname, cst_marital_status, cst_gndr, cst_create_date
    FROM cte_crm
    WHERE rn = 1;

    -- 2. Clean & Load crm_prd_info (Fixed cat_id extraction)
    TRUNCATE TABLE silver.crm_prd_info;
    WITH cleaned_prd_info AS (
        SELECT 
            prd_id,
            REPLACE(SUBSTRING(prd_key, 1, 5),'-','_') AS cat_id,
            REPLACE(SUBSTRING(prd_key, 7, LEN(prd_key)),'-','_') AS prd_key,
            prd_nm,
            ISNULL(prd_cost, 0) AS prd_cost,
            CASE prd_line 
                WHEN 'R' THEN 'Road'  
                WHEN 'S' THEN 'Standard'
                WHEN 'M' THEN 'Mountain'
                WHEN 'T' THEN 'Touring'
                ELSE 'N/A'
            END AS prd_line,
            prd_start_dt,
            DATEADD(DAY, -1, LEAD(prd_start_dt) OVER(PARTITION BY prd_key ORDER BY prd_start_dt)) AS prd_end_dt
        FROM bronze.crm_prd_info
    )
    INSERT INTO silver.crm_prd_info (prd_id,cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt)
    SELECT prd_id,cat_id, prd_key, prd_nm, prd_cost, prd_line, prd_start_dt, prd_end_dt
    FROM cleaned_prd_info;

    -- 3. Clean & Load crm_sales_details
    TRUNCATE TABLE silver.crm_sales_details;
    WITH cleaned_sales AS (
        SELECT 
            TRIM(sls_ord_num) AS sls_ord_num,
            REPLACE(TRIM(sls_prd_key),'-','_') AS sls_prd_key,
            sls_cust_id,
            TRY_CONVERT(DATE, CAST(sls_order_dt AS VARCHAR(8)), 112) AS sls_order_dt,
            TRY_CONVERT(DATE, CAST(sls_ship_dt AS VARCHAR(8)), 112) AS sls_ship_dt,
            TRY_CONVERT(DATE, CAST(sls_due_dt AS VARCHAR(8)), 112) AS sls_due_dt,
            CASE 
                WHEN sls_sales IS NULL OR sls_sales <= 0 OR sls_sales <> ABS(sls_quantity * sls_price)
                    THEN ABS(sls_quantity * sls_price) 
                ELSE sls_sales 
            END AS sls_sales,
            sls_quantity, 
            CASE 
                WHEN sls_price IS NULL OR sls_price <= 0 OR sls_price <> ABS(sls_sales / NULLIF(sls_quantity, 0))
                    THEN ABS(sls_sales / NULLIF(sls_quantity, 0)) 
                ELSE sls_price 
            END AS sls_price
        FROM bronze.crm_sales_details
    )
    INSERT INTO silver.crm_sales_details (sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price)
    SELECT sls_ord_num, sls_prd_key, sls_cust_id, sls_order_dt, sls_ship_dt, sls_due_dt, sls_sales, sls_quantity, sls_price
    FROM cleaned_sales;

    -- 4. Clean & Load erp_cust_az12
    TRUNCATE TABLE silver.erp_cust_az12;
    WITH cleaned_erp_cust AS (
        SELECT 
            CASE 
                WHEN CID LIKE 'NAS%' THEN REPLACE(CID, 'NAS', '')
                ELSE CID 
            END AS CID,
            CASE 
                WHEN BDATE > GETDATE() OR BDATE < '1920-01-01' THEN NULL
                ELSE BDATE
            END AS BDATE,
            CASE 
                WHEN UPPER(LEFT(TRIM(GEN), 1)) = 'M' THEN 'Male'
                WHEN UPPER(LEFT(TRIM(GEN), 1)) = 'F' THEN 'Female'
                ELSE 'N/A'
            END AS GEN
        FROM bronze.erp_cust_az12
    )
    INSERT INTO silver.erp_cust_az12 (CID, BDATE, GEN)
    SELECT CID, BDATE, GEN
    FROM cleaned_erp_cust;

    -- 5. Clean & Load erp_loc_a101
    TRUNCATE TABLE silver.erp_loc_a101;
    WITH cleaned_loc_a10 AS (
        SELECT 
            REPLACE(CID, '-', '') AS CID,
            CASE 
                WHEN UPPER(TRIM(CNTRY)) IN ('US', 'USA', 'UNITED STATES') THEN 'USA'
                WHEN UPPER(TRIM(CNTRY)) IN ('DE', 'GERMANY') THEN 'Germany'
                WHEN UPPER(TRIM(CNTRY)) IN ('UK', 'UNITED KINGDOM') THEN 'United Kingdom'
                WHEN UPPER(TRIM(CNTRY)) IN ('CA', 'CANADA') THEN 'Canada'
                WHEN UPPER(TRIM(CNTRY)) IN ('FR', 'FRANCE') THEN 'France'
                WHEN UPPER(TRIM(CNTRY)) IN ('AU', 'AUSTRALIA') THEN 'Australia'
                ELSE 'N/A'
            END AS CNTRY
        FROM bronze.erp_loc_a101
    )
    INSERT INTO silver.erp_loc_a101 (CID, CNTRY)
    SELECT CID, CNTRY
    FROM cleaned_loc_a10;

    -- 6. Clean & Load erp_px_cat_g1v2
    TRUNCATE TABLE silver.erp_px_cat_g1v2;
    WITH cleaned_px_cat_g1v2 AS (
        SELECT 
            ID, 
            CAT, 
            SUBCAT, 
            MAINTENANCE 
        FROM bronze.erp_px_cat_g1v2
    )
    INSERT INTO silver.erp_px_cat_g1v2 (ID, CAT, SUBCAT, MAINTENANCE)
    SELECT ID, CAT, SUBCAT, MAINTENANCE
    FROM cleaned_px_cat_g1v2;

END;
GO
EXEC silver.usp_importing_slvr
--checking results :
SELECT TOP 10 * FROM silver.crm_prd_info
SELECT TOP 10 * FROM silver.crm_cust_info
SELECT TOP 10 * FROM silver.crm_sales_details
SELECT TOP 10 * FROM silver.erp_px_cat_g1v2
SELECT TOP 10 * FROM silver.erp_loc_a101
SELECT TOP 10 * FROM silver.erp_cust_az12
