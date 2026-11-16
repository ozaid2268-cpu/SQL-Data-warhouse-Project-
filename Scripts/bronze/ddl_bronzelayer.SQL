-- ============================================================
-- SCRIPT DE CRÉATION DES TABLES - COUCHE BRONZE
-- ============================================================

-- 1. CRM : Sales Details
IF OBJECT_ID('bronze.crm_sales_details', 'U') IS NOT NULL 
    TRUNCATE TABLE bronze.crm_sales_details;
GO
CREATE TABLE bronze.crm_sales_details (
    sls_ord_num    VARCHAR(20)    NOT NULL,
    sls_prd_key    VARCHAR(20)    NOT NULL,
    sls_cust_id    INT            NOT NULL,
    sls_order_dt   INT            NOT NULL,  -- Format YYYYMMDD
    sls_ship_dt    INT            NOT NULL,  -- Format YYYYMMDD
    sls_due_dt     INT            NOT NULL,  -- Format YYYYMMDD
    sls_sales      INT            NOT NULL,
    sls_quantity   INT            NOT NULL,
    sls_price      INT            NOT NULL,
    PRIMARY KEY (sls_ord_num)
);
GO

-- 2. CRM : Customer Info
IF OBJECT_ID('bronze.crm_cust_info', 'U') IS NOT NULL 
    TRUNCATE TABLE bronze.crm_cust_info;
GO
CREATE TABLE bronze.crm_cust_info (
    cst_id              INT            NOT NULL,
    cst_key             VARCHAR(20)    NOT NULL,
    cst_firstname       VARCHAR(50)    NULL,
    cst_lastname        VARCHAR(50)    NULL,
    cst_marital_status  VARCHAR(1)     NULL,
    cst_gndr            VARCHAR(1)     NULL,
    cst_create_date     DATE           NULL,
    PRIMARY KEY (cst_id)
);
GO

-- 3. CRM : Product Info
IF OBJECT_ID('bronze.crm_prd_info', 'U') IS NOT NULL 
    TRUNCATE TABLE bronze.crm_prd_info;
GO
CREATE TABLE bronze.crm_prd_info (
    prd_id         INT            NOT NULL,
    prd_key        VARCHAR(30)    NOT NULL,
    prd_nm         VARCHAR(60)    NULL,
    prd_cost       INT            NULL,
    prd_line       VARCHAR(10)    NULL,
    prd_start_dt   DATE           NULL,
    prd_end_dt     DATE           NULL,
    PRIMARY KEY (prd_id)
);
GO

-- 4. ERP : Customer Birthdate & Gender
IF OBJECT_ID('bronze.erp_cust_az12', 'U') IS NOT NULL 
    TRUNCATE TABLE bronze.erp_cust_az12;
GO
CREATE TABLE bronze.erp_cust_az12 (
    cid     VARCHAR(20)   NOT NULL,
    bdate   DATE          NOT NULL,
    gen     VARCHAR(10)   NULL,
    PRIMARY KEY (cid)
);
GO

-- 5. ERP : Customer Location
IF OBJECT_ID('bronze.erp_loc_a101', 'U') IS NOT NULL 
    TRUNCATE TABLE bronze.erp_loc_a101;
GO
CREATE TABLE bronze.erp_loc_a101 (
    cid     VARCHAR(20)   NOT NULL,
    cntry   VARCHAR(30)   NULL,
    PRIMARY KEY (cid)
);
GO

-- 6. ERP : Product Category
IF OBJECT_ID('bronze.erp_px_cat_g1v2', 'U') IS NOT NULL 
    TRUNCATE TABLE bronze.erp_px_cat_g1v2;
GO
CREATE TABLE bronze.erp_px_cat_g1v2 (
    id            VARCHAR(10)   NOT NULL,
    cat           VARCHAR(20)   NOT NULL,
    subcat        VARCHAR(30)   NOT NULL,
    maintenance   VARCHAR(3)    NOT NULL,
    PRIMARY KEY (id)
);
GO
