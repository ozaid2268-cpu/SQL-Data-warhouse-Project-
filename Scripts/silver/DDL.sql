/* ============================================================
   Stored Procedure: silver.usp_Create_Silver_Tables
   ------------------------------------------------------------
   1. Creates the silver-layer schema tables for all 6 cleaned
      CRM & ERP datasets (mirrors bronze structure with refined
      data types: wider VARCHARs, proper DATE columns, no NULLs
      on key fields, added cat_id in prd_info).
   2. Idempotent by design — each table is DROP + CREATE, so the
      script can be re-run safely to rebuild the silver schema.
   3. Silver tables hold cleaned, standardized, typed data ready
      for joining and loading into the gold layer.
   4. Executed automatically at the end via
      EXEC silver.usp_Create_Silver_Tables.
   5. ⚠️ WARNING: DROP TABLE will delete all existing silver data
      — run this only during setup or a full rebuild.
   ============================================================ */
--creating Tables for schema silver :
CREATE OR ALTER PROCEDURE silver.usp_Create_Silver_Tables
AS
BEGIN
    SET NOCOUNT ON;
    
    /* ============================================================
       CRM TABLES
       ============================================================ */

    /* Creating table: silver.crm_cust_info */
    IF OBJECT_ID('silver.crm_cust_info', 'U') IS NOT NULL
        DROP TABLE silver.crm_cust_info;

    CREATE TABLE silver.crm_cust_info
    (
        cst_id              INT             NULL,
        cst_key             VARCHAR(20)     NULL,
        cst_firstname       NVARCHAR(30)   NULL,
        cst_lastname        NVARCHAR(30)   NULL,
        cst_marital_status  CHAR(10)         NULL,
        cst_gndr            CHAR(10)         NULL,
        cst_create_date     DATE            NULL
    );

    /* Creating table: silver.crm_prd_info */
    IF OBJECT_ID('silver.crm_prd_info', 'U') IS NOT NULL
        DROP TABLE silver.crm_prd_info;

    CREATE TABLE silver.crm_prd_info
    (
        prd_id          INT             ,
        cat_id         VARCHAR(50)     ,
        prd_key         VARCHAR(50)     ,
        prd_nm          NVARCHAR(100)   ,
        prd_cost        INT             NULL,
        prd_line        CHAR(10)         NULL,
        prd_start_dt    DATE            NULL,
        prd_end_dt      DATE            NULL
    );

    /* Creating table: silver.crm_sales_details */
    IF OBJECT_ID('silver.crm_sales_details', 'U') IS NOT NULL
        DROP TABLE silver.crm_sales_details;

    CREATE TABLE silver.crm_sales_details
    (
        sls_ord_num     VARCHAR(50)     NULL,
        sls_prd_key     VARCHAR(50)     NULL,
        sls_cust_id     INT             NULL,
        sls_order_dt    DATE             NULL,
        sls_ship_dt     DATE            NULL,
        sls_due_dt      DATE             NULL,
        sls_sales       INT             NULL,
        sls_quantity    INT             NULL,
        sls_price       INT             NULL
    );

    /* ============================================================
       ERP TABLES
       ============================================================ */

    /* Creating table: silver.erp_cust_az12 */
    IF OBJECT_ID('silver.erp_cust_az12', 'U') IS NOT NULL
        DROP TABLE silver.erp_cust_az12;

    CREATE TABLE silver.erp_cust_az12
    (
        CID     VARCHAR(50)     NULL,
        BDATE   DATE            NULL,
        GEN     VARCHAR(50)     NULL
    );

    /* Creating table: silver.erp_loc_a101 */
    IF OBJECT_ID('silver.erp_loc_a101', 'U') IS NOT NULL
        DROP TABLE silver.erp_loc_a101;

    CREATE TABLE silver.erp_loc_a101
    (
        CID     VARCHAR(50)     NULL,
        CNTRY   VARCHAR(50)     NULL
    );

    /* Creating table: silver.erp_px_cat_g1v2 */
    IF OBJECT_ID('silver.erp_px_cat_g1v2', 'U') IS NOT NULL
        DROP TABLE silver.erp_px_cat_g1v2;

    CREATE TABLE silver.erp_px_cat_g1v2
    (
        ID           VARCHAR(50)   NULL,
        CAT          VARCHAR(50)   NULL,
        SUBCAT       VARCHAR(50)   NULL,
        MAINTENANCE  CHAR(10)       NULL
    );
END;
GO
EXEC silver.usp_Create_Silver_Tables
