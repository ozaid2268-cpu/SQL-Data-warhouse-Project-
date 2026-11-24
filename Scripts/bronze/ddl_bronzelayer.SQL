/* ============================================================
   Bronze Layer - Table Creation Script (DDL)
   ------------------------------------------------------------
   1. Creates raw ingestion tables in the 'bronze' schema for CRM
      (cust_info, prd_info, sales_details) and ERP (cust_az12,
      loc_a101, px_cat_g1v2) source systems.
   2. Each block drops the existing table if present (idempotent)
      and recreates it with all columns as NULL to preserve
      source data integrity before any transformation.
   3. All fields are loaded as-is (no cleaning) — typing and
      casting are handled downstream in the silver layer.
   4. Run this script once per environment setup or whenever the
      bronze schema needs to be reset/rebuilt from scratch.
   ============================================================ */
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_cust_info;

CREATE TABLE bronze.crm_cust_info
(
    cst_id              INT             NULL,
    cst_key             VARCHAR(20)     NULL,
    cst_firstname       NVARCHAR(20)   NULL,
    cst_lastname        NVARCHAR(20)   NULL,
    cst_marital_status  CHAR(10)         NULL,
    cst_gndr            CHAR(10)         NULL,
    cst_create_date     DATE            NULL
);

/* Creating table: bronze1.crm_prd_info */
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL
    DROP TABLE bronze.crm_prd_info;

CREATE TABLE bronze.crm_prd_info
(
    prd_id          INT             NULL,
    prd_key         VARCHAR(30)     NULL,
    prd_nm          NVARCHAR(50)   NULL,
    prd_cost        INT             NULL,
    prd_line        CHAR(15)         NULL,
    prd_start_dt    DATE            NULL,
    prd_end_dt      DATE            NULL
);

/* Creating table: bronze1.crm_sales_details */
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL
    DROP TABLE bronze.crm_sales_details;

CREATE TABLE bronze.crm_sales_details
(
    sls_ord_num     VARCHAR(15)     NULL,
    sls_prd_key     VARCHAR(30)     NULL,
    sls_cust_id     INT             NULL,
    sls_order_dt    INT             NULL,
    sls_ship_dt     INT             NULL,
    sls_due_dt      INT             NULL,
    sls_sales       INT             NULL,
    sls_quantity    INT             NULL,
    sls_price       INT             NULL
);

/* ============================================================
   ERP TABLES
   ============================================================ */

/* Creating table: bronze1.erp_cust_az12
   (source: CUST_AZ12.csv — CID, BDATE, GEN) */
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL
    DROP TABLE bronze.erp_cust_az12;

CREATE TABLE bronze.erp_cust_az12
(
    CID     VARCHAR(20)     NULL,
    BDATE   DATE            NULL,
    GEN     VARCHAR(10)     NULL
);

/* Creating table: bronze1.erp_loc_a101
   (placeholder — send the CSV header and I will fill in the columns) */
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL
    DROP TABLE bronze.erp_loc_a101;
 CREATE TABLE bronze.erp_loc_a101
 (
    CID     VARCHAR(50)     NULL,
    CNTRY   VARCHAR(50)     NULL
 );

/* Creating table: bronze1.erp_px_cat_g1v2
   (placeholder — send the CSV header and I will fill in the columns) */
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL
     DROP TABLE bronze.erp_px_cat_g1v2;
CREATE TABLE bronze.erp_px_cat_g1v2
 (
     ID           VARCHAR(10)   NULL,
     CAT          VARCHAR(50)   NULL,
     SUBCAT       VARCHAR(50)   NULL,
     MAINTENANCE  CHAR(4)       NULL
 );
