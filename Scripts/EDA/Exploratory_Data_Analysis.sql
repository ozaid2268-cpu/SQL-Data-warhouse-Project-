--Exploratory Data Analysis :
--several antyties
-- Distinct values for Products
SELECT DISTINCT category FROM gold.dim_products;
SELECT DISTINCT subcategory FROM gold.dim_products;
SELECT DISTINCT maintenance FROM gold.dim_products;

-- Distinct values for Customers
SELECT DISTINCT gender FROM gold.dim_customers;
SELECT DISTINCT martial_status FROM gold.dim_customers;
SELECT DISTINCT country FROM gold.dim_customers;

-- Distinct values for Fact Sales
SELECT DISTINCT quantity FROM gold.fact_sales;

--1 DATE EXPLORATION

-- Min and Max dates in the Fact table
SELECT 
    MIN(order_date) AS min_order_date, 
    MAX(order_date) AS max_order_date,
    DATEDIFF(day, MIN(order_date), MAX(order_date)) AS total_days_of_data
FROM gold.fact_sales;

-- Shipping Lead Times (Average, Min, Max differences)
SELECT 
    AVG(DATEDIFF(day, order_date, ship_date)) AS avg_days_to_ship,
    MIN(DATEDIFF(day, order_date, ship_date)) AS min_days_to_ship,
    MAX(DATEDIFF(day, order_date, ship_date)) AS max_days_to_ship,
    AVG(DATEDIFF(day, ship_date, due_date)) AS avg_transit_days
FROM gold.fact_sales;

-- Customer Age Exploration (Min/Max Birthdates)
SELECT 
    MIN(birthdate) AS oldest_customer, 
    MAX(birthdate) AS youngest_customer
FROM gold.dim_customers;

-- Product Lifespan (Active vs Discontinued)
SELECT 
    SUM(CASE WHEN end_dt IS NULL THEN 1 ELSE 0 END) AS active_products,
    SUM(CASE WHEN end_dt IS NOT NULL THEN 1 ELSE 0 END) AS discontinued_products
FROM gold.dim_products;

--Measure Exploration :
-- Sales, Price, and Quantity Ranges
SELECT 
    MIN(sales_amount) AS min_sales,
    MAX(sales_amount) AS max_sales,
    AVG(sales_amount) AS avg_sales,
    
    MIN(price) AS min_price,
    MAX(price) AS max_price,
    AVG(price) AS avg_price,
    
    MIN(quantity) AS min_qty,
    MAX(quantity) AS max_qty,
    AVG(quantity) AS avg_qty
FROM gold.fact_sales;

-- Checking for negative values (Returns/Errors)
SELECT 
    COUNT(*) AS total_rows,
    SUM(CASE WHEN sales_amount < 0 THEN 1 ELSE 0 END) AS negative_sales,
    SUM(CASE WHEN quantity <= 0 THEN 1 ELSE 0 END) AS zero_or_negative_qty
FROM gold.fact_sales;

-- Top 10 Highest Revenue Orders (Using TOP instead of LIMIT)
SELECT TOP 10
    order_number, 
    sales_amount 
FROM gold.fact_sales 
ORDER BY sales_amount DESC;

-- Total Revenue, Total Units Sold, and Average Order Value (AOV)
-- Note: Multiplied by 1.0 to force decimal division, otherwise SQL Server does integer division
SELECT 
    SUM(sales_amount) AS total_revenue,
    SUM(quantity) AS total_units_sold,
    (SUM(sales_amount) * 1.0) / COUNT(DISTINCT order_number) AS average_order_value
FROM gold.fact_sales;

-- Most expensive products in the catalog
SELECT TOP 10
    product_name, 
    cost, 
    category 
FROM gold.dim_products 
ORDER BY cost DESC;
--Cardinality :

-- High Cardinality Checks
SELECT COUNT(DISTINCT order_number) AS unique_orders FROM gold.fact_sales;
SELECT COUNT(DISTINCT customer_key) AS unique_customers FROM gold.dim_customers;

-- Note: Your image showed 'prdky' and 'product_key'. If your dim_products 
-- primary key is product_sk, use that. If it's product_key, use that.
SELECT COUNT(DISTINCT product_key) AS unique_products FROM gold.dim_products; 

-- Low Cardinality Check (Count of rows per category)
SELECT 
    gender, 
    COUNT(*) AS customer_count 
FROM gold.dim_customers 
GROUP BY gender;

SELECT 
    category, 
    COUNT(*) AS product_count 
FROM gold.dim_products 
GROUP BY category;
-- Table showiing All EDA in one :
--TIME SERIES :
SELECT 
    YEAR(order_date) AS Order_Year,
    MONTH(order_date) AS Order_Month,
    SUM(sales_amount) AS Revenue,
    SUM(quantity) AS Units_Sold
FROM gold.fact_sales
WHERE order_date <= '2025-12-31' -- Filters out that crazy 5489 date!
GROUP BY YEAR(order_date), MONTH(order_date)
ORDER BY Order_Year, Order_Month;
--Sales by Product Category
SELECT 
    p.category,
    SUM(f.sales_amount) AS Revenue,
    SUM(f.quantity) AS Units_Sold
FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON f.product_sk = p.product_sk
GROUP BY p.category
ORDER BY Revenue DESC;
--TOP 10 Customers :
SELECT TOP 10
    c.firstname + ' ' + c.lastname AS Customer_Name,
    c.country,
    SUM(f.sales_amount) AS Total_Spend
FROM gold.fact_sales f
LEFT JOIN gold.dim_customers c ON f.customer_rk = c.customer_rk
GROUP BY c.firstname, c.lastname, c.country
ORDER BY Total_Spend DESC;
