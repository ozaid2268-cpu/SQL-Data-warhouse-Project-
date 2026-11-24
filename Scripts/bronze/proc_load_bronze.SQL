/* ============================================================
   Stored Procedure: bronze.usp_Load_Bronze_Tables
   ------------------------------------------------------------
   1. Master loader for the bronze layer: truncates and reloads
      all 6 raw source tables (3 CRM + 3 ERP) from CSV files via
      BULK INSERT with UTF-8 codepage and header row skipping.
   2. Idempotent by design — TRUNCATE before each load guarantees
      a clean, repeatable full refresh on every execution.
   3. Tracks performance: logs per-table load time plus total
      CRM and ERP durations using SYSDATETIME/DATEDIFF.
   4. Ends with an audit summary (UNION ALL) showing row counts
      per table, so you can verify all sources loaded successfully.
   ============================================================ */
CREATE OR ALTER PROCEDURE bronze.usp_Load_Bronze_Tables
AS
BEGIN
    SET NOCOUNT ON;

    DECLARE @start_crm   DATETIME2 = SYSDATETIME();
    DECLARE @start_erp   DATETIME2 = SYSDATETIME();
    DECLARE @start_tbl   DATETIME2;
    DECLARE @duration    INT;

    /* ============================================================
       LOADING CRM TABLES
       ============================================================ */
    PRINT '============================================';
    PRINT 'START LOADING CRM TABLES';
    PRINT '============================================';

    /* ------------------------------------------------------------
       Loading table bronze.crm_cust_info
       Source: C:\path\to\cust_info.csv
       ------------------------------------------------------------ */
    PRINT 'Loading table bronze.crm_cust_info ...';
    SET @start_tbl = SYSDATETIME();

    TRUNCATE TABLE bronze.crm_cust_info;

    BULK INSERT bronze.crm_cust_info
    FROM 'C:\path\to\cust_info.csv'
    WITH (
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '\n',
        CODEPAGE        = '65001'
    );

    SET @duration = DATEDIFF(SECOND, @start_tbl, SYSDATETIME());
    PRINT 'Loaded bronze.crm_cust_info in ' + CAST(@duration AS VARCHAR(10)) + ' s';

    /* ------------------------------------------------------------
       Loading table bronze.crm_prd_info
       Source: C:\path\to\prd_info.csv
       ------------------------------------------------------------ */
    PRINT 'Loading table bronze.crm_prd_info ...';
    SET @start_tbl = SYSDATETIME();

    TRUNCATE TABLE bronze.crm_prd_info;

    BULK INSERT bronze.crm_prd_info
    FROM 'C:\path\to\prd_info.csv'
    WITH (
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '\n',
        CODEPAGE        = '65001'
    );

    SET @duration = DATEDIFF(SECOND, @start_tbl, SYSDATETIME());
    PRINT 'Loaded bronze.crm_prd_info in ' + CAST(@duration AS VARCHAR(10)) + ' s';

    /* ------------------------------------------------------------
       Loading table bronze.crm_sales_details
       Source: C:\path\to\sales_details.csv
       ------------------------------------------------------------ */
    PRINT 'Loading table bronze.crm_sales_details ...';
    SET @start_tbl = SYSDATETIME();

    TRUNCATE TABLE bronze.crm_sales_details;

    BULK INSERT bronze.crm_sales_details
    FROM 'C:\path\to\sales_details.csv'
    WITH (
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '\n',
        CODEPAGE        = '65001'
    );

    SET @duration = DATEDIFF(SECOND, @start_tbl, SYSDATETIME());
    PRINT 'Loaded bronze.crm_sales_details in ' + CAST(@duration AS VARCHAR(10)) + ' s';

    /* ------------------------------------------------------------
       Global duration for CRM loading
       ------------------------------------------------------------ */
    SET @duration = DATEDIFF(SECOND, @start_crm, SYSDATETIME());
    PRINT '--------------------------------------------';
    PRINT 'CRM LOADING COMPLETED IN ' + CAST(@duration AS VARCHAR(10)) + ' s';
    PRINT '--------------------------------------------';


    /* ============================================================
       LOADING ERP TABLES
       ============================================================ */
    PRINT '============================================';
    PRINT 'START LOADING ERP TABLES';
    PRINT '============================================';
    SET @start_erp = SYSDATETIME();

    /* ------------------------------------------------------------
       Loading table bronze.erp_cust_az12
       Source: C:\path\to\CUST_AZ12.csv
       ------------------------------------------------------------ */
    PRINT 'Loading table bronze.erp_cust_az12 ...';
    SET @start_tbl = SYSDATETIME();

    TRUNCATE TABLE bronze.erp_cust_az12;

    BULK INSERT bronze.erp_cust_az12
    FROM 'C:\path\to\CUST_AZ12.csv'
    WITH (
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '\n',
        CODEPAGE        = '65001'
    );

    SET @duration = DATEDIFF(SECOND, @start_tbl, SYSDATETIME());
    PRINT 'Loaded bronze.erp_cust_az12 in ' + CAST(@duration AS VARCHAR(10)) + ' s';

    /* ------------------------------------------------------------
       Loading table bronze.erp_loc_a101
       Source: C:\path\to\LOC_A101.csv
       ------------------------------------------------------------ */
    PRINT 'Loading table bronze.erp_loc_a101 ...';
    SET @start_tbl = SYSDATETIME();

    TRUNCATE TABLE bronze.erp_loc_a101;

    BULK INSERT bronze.erp_loc_a101
    FROM 'C:\path\to\LOC_A101.csv'
    WITH (
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '\n',
        CODEPAGE        = '65001'
    );

    SET @duration = DATEDIFF(SECOND, @start_tbl, SYSDATETIME());
    PRINT 'Loaded bronze.erp_loc_a101 in ' + CAST(@duration AS VARCHAR(10)) + ' s';

    /* ------------------------------------------------------------
       Loading table bronze.erp_px_cat_g1v2
       Source: C:\path\to\PX_CAT_G1V2.csv
       ------------------------------------------------------------ */
    PRINT 'Loading table bronze.erp_px_cat_g1v2 ...';
    SET @start_tbl = SYSDATETIME();

    TRUNCATE TABLE bronze.erp_px_cat_g1v2;

    BULK INSERT bronze.erp_px_cat_g1v2
    FROM 'C:\path\to\PX_CAT_G1V2.csv'
    WITH (
        FIRSTROW        = 2,
        FIELDTERMINATOR = ',',
        ROWTERMINATOR   = '\n',
        CODEPAGE        = '65001'
    );

    SET @duration = DATEDIFF(SECOND, @start_tbl, SYSDATETIME());
    PRINT 'Loaded bronze.erp_px_cat_g1v2 in ' + CAST(@duration AS VARCHAR(10)) + ' s';

    /* ------------------------------------------------------------
       Global duration for ERP loading
       ------------------------------------------------------------ */
    SET @duration = DATEDIFF(SECOND, @start_erp, SYSDATETIME());
    PRINT '--------------------------------------------';
    PRINT 'ERP LOADING COMPLETED IN ' + CAST(@duration AS VARCHAR(10)) + ' s';
    PRINT '--------------------------------------------';


    /* ============================================================
       SPECIAL LOADING (summary / audit)
       ============================================================ */
    PRINT '============================================';
    PRINT 'SPECIAL LOADING (SUMMARY)';
    PRINT '============================================';

    SELECT 'bronze.crm_cust_info'     AS table_name, COUNT(*) AS row_count FROM bronze.crm_cust_info
    UNION ALL
    SELECT 'bronze.crm_prd_info',              COUNT(*) FROM bronze.crm_prd_info
    UNION ALL
    SELECT 'bronze.crm_sales_details',         COUNT(*) FROM bronze.crm_sales_details
    UNION ALL
    SELECT 'bronze.erp_cust_az12',             COUNT(*) FROM bronze.erp_cust_az12
    UNION ALL
    SELECT 'bronze.erp_loc_a101',              COUNT(*) FROM bronze.erp_loc_a101
    UNION ALL
    SELECT 'bronze.erp_px_cat_g1v2',           COUNT(*) FROM bronze.erp_px_cat_g1v2;

    PRINT '============================================';
    PRINT 'ALL LOADING COMPLETED';
    PRINT '============================================';
END;
GO
