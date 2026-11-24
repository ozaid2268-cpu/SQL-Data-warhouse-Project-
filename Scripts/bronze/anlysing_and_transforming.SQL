/* ============================================================
   Bronze Layer - Data Exploration & Cleaning (Transformations)
   ------------------------------------------------------------
   1. Profiles each bronze source table (CRM & ERP) to understand
      structure, then tests for NULLs, duplicates, whitespace,
      invalid dates, and inconsistent coded values before cleaning.
   2. Applies cleaning per table via CTEs: trims strings, maps
      coded values (marital status, gender, product line, country),
      deduplicates customers, fixes date formats & invalid numbers.
   3. Business rules enforced: recalculates inconsistent sales/price
      values, strips 'NAS' prefix from CRM IDs, removes '-' from ERP IDs.
   4. Output of each CTE is a cleaned dataset ready to be written
      into the silver layer — this file is for exploration/prototyping.
   5. Note: some queries are ad-hoc checks; only the final CTE
      SELECTs represent the cleaned output.
   ============================================================ */
-- FETCHING ALL TABLES FOR REALTIONS (Architecture):
SELECT TOP 10 * FROM bronze.crm_cust_info
SELECT TOP 10 * FROM bronze.crm_prd_info
SELECT TOP 10 * FROM bronze.crm_sales_details
SELECT TOP 10 * FROM bronze.erp_cust_az12
SELECT TOP 10 * FROM bronze.erp_loc_a101
SELECT TOP 10 * FROM bronze.erp_px_cat_g1v2
--After analysing columns and doing relations graphicly we do transformations:
SELECT TOP 10 cst_id
,cst_key
,cst_firstname
,cst_lastname
,cst_marital_status
,cst_gndr
,cst_create_date
FROM bronze.crm_cust_info
--Testing for Table bronze.crm_cust_info
SELECT TOP 10 cst_id
,cst_key
,cst_firstname
,cst_lastname
,cst_marital_status
,cst_gndr
,cst_create_date
FROM bronze.crm_cust_info
--group cleaned crm_cust_info
WITH cte_crm AS
(
    SELECT
        cst_id,
        cst_key,
        TRIM(cst_firstname) firstname,
        TRIM(cst_lastname) lastname,
        CASE UPPER(TRIM(cst_marital_status)) 
        WHEN 'M' Then 'Married'
        WHEN 'S' THEN 'Single'
        ELSE 'N/A'
        END AS cst_marital_status,
        CASE UPPER(TRIM(cst_gndr)) 
        WHEN 'M' Then 'Male'
        WHEN 'F' THEN 'Female'
        ELSE 'N/A'
        END cst_gndr,
        cst_create_date,
        ROW_NUMBER() OVER (
            PARTITION BY cst_id
            ORDER BY cst_create_date DESC
        ) AS rn
    FROM bronze.crm_cust_info
    WHERE cst_id IS NOT NULL           -- don't lump all NULL ids into one partition
)
SELECT *
FROM cte_crm
WHERE rn = 1;

SELECT cst_id,count(*)
FROM bronze.crm_cust_info GROUP BY cst_id HAVING COUNT(*)!=1
--For doing data Mapping (look more good) we select distinct all values 
SELECT DISTINCT cst_marital_status FROM bronze.crm_cust_info
--Same thing for Gender :
SELECT DISTINCT cst_gndr FROM bronze.crm_cust_info
-- CHEKING FOR COLUMNS COUNTAINS ' ' 
SELECT cst_key FROM bronze.crm_cust_info WHERE cst_key!=TRIM(cst_key)
SELECT cst_firstname FROM bronze.crm_cust_info WHERE cst_lastname!=TRIM(cst_lastname)
SELECT cst_create_date FROM bronze.crm_cust_info WHERE cst_create_date is null 
--TABLE bronze.cust_prd_info
--Testing for Table bronze.prd_cust_info
SELECT TOP 10 * FROM bronze.crm_prd_info
--no duplicates in id 
SELECT COUNT(*) , prd_id FROM bronze.crm_prd_info GROUP BY prd_id HAVING COUNT(*)>1

--no ' ' in prd_line
SELECT prd_line FROM bronze.crm_prd_info WHERE prd_line!=TRIM(prd_line)

--no ' ' in prd_nm
SELECT prd_nm FROM bronze.crm_prd_info WHERE prd_nm!=TRIM(prd_nm)

--two nulls in cost we change them to a zeros 
SELECT ISNULL(prd_cost,0) FROM bronze.crm_prd_info  
--
SELECT TOP 10 
REPLACE(SUBSTRING(prd_key,1,5),'-','_') AS prd_ID,
REPLACE(SUBSTRING(prd_key,7,LEN(prd_key)),'-','_') AS prd_key
FROM bronze.crm_prd_info
SELECT TOP 10 * FROM bronze.erp_px_cat_g1v2
SELECT TOP 10 * FROM bronze.crm_sales_details

SELECT TOP 10 * From bronze.crm_prd_info
--problem of start and end dates


SELECT TOP 10 * FROM bronze.erp_px_cat_g1v2
SELECT TOP 10 * FROM bronze.crm_sales_details
SELECT LEAD(prd_start_dt) OVER (
    PARTITION BY prd_key 
    ORDER BY prd_start_dt
)  FROM bronze.crm_prd_info
-- Group cleaned crm_prd_info
WITH cleaned_prd_info AS (
    SELECT 
        prd_id,
        REPLACE(SUBSTRING(prd_key, 1, 5), '-', '_') AS cat_id,
        REPLACE(SUBSTRING(prd_key, 7, LEN(prd_key)), '-', '_') AS prd_key,
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
        prd_end_dt
    FROM bronze.crm_prd_info
)
-- You must have a final statement after the CTE
SELECT * FROM cleaned_prd_info;

--Now table cust_Sales_Details 
SELECT TOP 10 * FROM bronze.crm_sales_details
--Testing : 
--cheking for empty spaces 
SELECT *
FROM bronze.crm_sales_details
WHERE sls_ord_num <> TRIM(sls_ord_num) 
   OR sls_prd_key <> TRIM(sls_prd_key);
--Converts integer YYYYMMDD (style 112) to DATE format 'yyyy-MM-dd' and safely returns NULL for invalid/0 dates. 
WITH formating_day AS (
SELECT 
TRY_CONVERT(DATE, CAST(sls_order_dt AS VARCHAR(8)), 112) AS sls_order_dt,
TRY_CONVERT(DATE, CAST(sls_ship_dt AS VARCHAR(8)), 112) AS sls_ship_dt,
TRY_CONVERT(DATE, CAST(sls_due_dt AS VARCHAR(8)), 112) AS sls_due_dt
FROM bronze.crm_sales_details  )
SELECT * FROM formating_day WHERE sls_order_dt<'5489-01-01'
-- Flags any row where sales, quantity, or price is missing, negative, or zero.
 SELECT 
    sls_sales, 
    sls_quantity, 
    sls_price
FROM bronze.crm_sales_details
WHERE sls_sales IS NULL OR sls_sales <= 0
   OR sls_quantity IS NULL OR sls_quantity <= 0
   OR sls_price IS NULL OR sls_price <= 0;
   SELECT sls_price,sls_quantity,sls_sales FROM bronze.crm_sales_details where sls_quantity>1
-- Fixes: Recalculates Sales (Quantity * Price) and Price (Sales / Quantity) if they are NULL,
-- <= 0, or mathematically inconsistent with each other (handles the 50 vs 100 issue in the image).
SELECT 
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
FROM bronze.crm_sales_details;
SELECT TOP 10 * FROM bronze.crm_sales_details
--Grouping cleaned table crm_slaes_details 
WITH cleaned_sales AS (
    SELECT 
        TRIM(sls_ord_num) AS sls_ord_num,
        TRIM(sls_prd_key) AS sls_prd_key,
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
SELECT * FROM cleaned_sales;
--cleaning tables from ERP 
SELECT TOP 10 * FROM bronze.erp_cust_az12
--cheking for syntax differences in gender
SELECT DISTINCT GEN FROM bronze.erp_cust_az12
SELECT 
    GEN AS original_gen,
    CASE 
        WHEN UPPER(LEFT(TRIM(GEN), 1)) = 'M' THEN 'Male'
        WHEN UPPER(LEFT(TRIM(GEN), 1)) = 'F' THEN 'Female'
        ELSE 'N/A'
    END AS standardized_gen
FROM bronze.erp_cust_az12
--CTE for clean bronze.erp_cust_az12
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
SELECT * FROM cleaned_erp_cust;

--cleaned cte table bronze.erp_loc_a101
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
SELECT * FROM cleaned_loc;
--Cleaning table bronze.erp_px_cat_g1v2
SELECT TOP 10 * FROM bronze.erp_px_cat_g1v2
SELECT MAINTENANCE
FROM bronze.erp_px_cat_g1v2 where MAINTENANCE!=TRIM(MAINTENANCE)
SELECT DISTINCT MAINTENANCE FROM bronze.erp_px_cat_g1v2 
SELECT DISTINCT CAT FROM bronze.erp_px_cat_g1v2 
SELECT DISTINCT SUBCAT FROM bronze.erp_px_cat_g1v2 
SELECT DISTINCT FROM bronze.erp_px_cat_g1v2 
WITH cleaned_px_cat_g1v2 AS(
SELECT ID,CAT,SUBCAT,MAINTENANCE FROM bronze.erp_px_cat_g1v2)
SELECT * FROM cleaned_px_cat_g1v2
