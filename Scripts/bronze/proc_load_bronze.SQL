/* ============================================================
   Procedure : bronze.load_procedure
   Purpose   : Load all raw CSV files from the CRM and ERP 
               sources into the Bronze layer of the Data Warehouse.
   
   How it works: 
     1. Truncates each target table to ensure a clean, full refresh.
     2. Uses BULK INSERT to quickly ingest raw data from the 
        CSV files.
     3. Captures and prints the execution time (in ms and seconds) 
        for each table load using PRINT statements, providing 
        basic performance monitoring.
   ============================================================ */
CREATE OR ALTER PROCEDURE bronze.load_procedure
AS
BEGIN
    DECLARE @batch_start_time DATETIME
    DECLARE @batch_end_time DATETIME
    DECLARE @start_time   DATETIME2;
    DECLARE @end_time     DATETIME2;
    DECLARE @duration_ms  INT;
    PRINT '=================================================';
    PRINT 'Starting Bronze layer load...';
    PRINT '=================================================';


    /* ========================================================
       LOADING CRM SOURCE TABLES
       ======================================================== */
    PRINT '-------------------------------------------------';
    PRINT 'Loading CRM source tables...';
    PRINT '-------------------------------------------------';
    SET @batch_start_time=GETDATE();
    -- Loading table: bronze.crm_sales_details
    PRINT '>> Loading table: bronze.crm_sales_details ...';
    SET @start_time = SYSDATETIME();
    TRUNCATE TABLE bronze.crm_sales_details;
    BULK INSERT bronze.crm_sales_details
    FROM 'C:\Users\hp\Desktop\tous\SQL\sql-data-warehouse-project\datasets\source_crm\sales_details.csv'
    WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK );
    SET @end_time    = SYSDATETIME();
    SET @duration_ms = DATEDIFF(MILLISECOND, @start_time, @end_time);
    PRINT '>> Done: bronze.crm_sales_details |  Duration: '
          + CAST(@duration_ms AS VARCHAR(20)) + ' ms ('
          + CAST(@duration_ms / 1000.0 AS VARCHAR(20)) + ' s'
    -- Loading table: bronze.crm_cust_info
    PRINT '>> Loading table: bronze.crm_cust_info ...';
    SET @start_time = SYSDATETIME();
    TRUNCATE TABLE bronze.crm_cust_info;
    BULK INSERT bronze.crm_cust_info
    FROM 'C:\Users\hp\Desktop\tous\SQL\sql-data-warehouse-project\datasets\source_crm\cust_info.csv'
    WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK );
    SET @end_time    = SYSDATETIME();
    SET @duration_ms = DATEDIFF(MILLISECOND, @start_time, @end_time);
    PRINT '>> Done: bronze.crm_cust_info|  Duration: '
          + CAST(@duration_ms AS VARCHAR(20)) + ' ms ('
          + CAST(@duration_ms / 1000.0 AS VARCHAR(20)) + ' s';

    -- Loading table: bronze.crm_prd_info
    PRINT '>> Loading table: bronze.crm_prd_info ...';
    SET @start_time = SYSDATETIME();
    TRUNCATE TABLE bronze.crm_prd_info;
    BULK INSERT bronze.crm_prd_info
    FROM 'C:\Users\hp\Desktop\tous\SQL\sql-data-warehouse-project\datasets\source_crm\prd_info.csv'
    WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK );
    SET @end_time    = SYSDATETIME();
    SET @duration_ms = DATEDIFF(MILLISECOND, @start_time, @end_time);
    PRINT '>> Done: bronze.crm_prd_info  |  Duration: '
          + CAST(@duration_ms AS VARCHAR(20)) + ' ms ('
          + CAST(@duration_ms / 1000.0 AS VARCHAR(20)) + ' s)';


    /* ========================================================
       LOADING ERP SOURCE TABLES
       ======================================================== */
    PRINT '-------------------------------------------------';
    PRINT 'Loading ERP source tables...';
    PRINT '-------------------------------------------------';

    -- Loading table: bronze.erp_cust_az12
    PRINT '>> Loading table: bronze.erp_cust_az12 ...';
    SET @start_time = SYSDATETIME();
    TRUNCATE TABLE bronze.erp_cust_az12;
    BULK INSERT bronze.erp_cust_az12
    FROM 'C:\Users\hp\Desktop\tous\SQL\sql-data-warehouse-project\datasets\source_erp\CUST_AZ12.csv'
    WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK );
    SET @end_time    = SYSDATETIME();
    SET @duration_ms = DATEDIFF(MILLISECOND, @start_time, @end_time);
    PRINT '>> Done: bronze.erp_cust_az12 |  Duration: '
          + CAST(@duration_ms AS VARCHAR(20)) + ' ms ('
          + CAST(@duration_ms / 1000.0 AS VARCHAR(20)) + ' s)';

    -- Loading table: bronze.erp_loc_a101
    PRINT '>> Loading table: bronze.erp_loc_a101 ...';
    SET @start_time = SYSDATETIME();
    TRUNCATE TABLE bronze.erp_loc_a101;
    BULK INSERT bronze.erp_loc_a101
    FROM 'C:\Users\hp\Desktop\tous\SQL\sql-data-warehouse-project\datasets\source_erp\LOC_A101.csv'
    WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK );
    SET @end_time    = SYSDATETIME();
    SET @duration_ms = DATEDIFF(MILLISECOND, @start_time, @end_time);
    PRINT '>> Done: bronze.erp_loc_a101 |  Duration: '
          + CAST(@duration_ms AS VARCHAR(20)) + ' ms ('
          + CAST(@duration_ms / 1000.0 AS VARCHAR(20)) + ' s)';

    -- Loading table: bronze.erp_px_cat_g1v2
    PRINT '>> Loading table: bronze.erp_px_cat_g1v2 ...';
    SET @start_time = SYSDATETIME();
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
    BULK INSERT bronze.erp_px_cat_g1v2
    FROM 'C:\Users\hp\Desktop\tous\SQL\sql-data-warehouse-project\datasets\source_erp\PX_CAT_G1V2.csv'
    WITH ( FIRSTROW = 2, FIELDTERMINATOR = ',', TABLOCK );
    SET @end_time    = SYSDATETIME();
    SET @duration_ms = DATEDIFF(MILLISECOND, @start_time, @end_time);
    PRINT '>> Done: bronze.erp_px_cat_g1v2 |  Duration: '
          + CAST(@duration_ms AS VARCHAR(20)) + ' ms ('
          + CAST(@duration_ms / 1000.0 AS VARCHAR(20)) + ' s)';

    SET @batch_end_time=GETDATE()
    PRINT '=================================================';
    PRINT 'Bronze layer load completed successfully'+ CAST(DATEDIFF(second,@batch_end_time,@batch_start_time) AS NVARCHAR) ;
    PRINT 'Total Load Time'+ CAST(DATEDIFF(second,@batch_end_time,@batch_start_time) AS NVARCHAR) +'seconds' ;
    PRINT '=================================================';
    

END
GO
