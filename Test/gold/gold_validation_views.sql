--Check for Orphaned Records (Missing Keys) :
-- Check for missing product keys in Fact
SELECT COUNT(*) AS missing_product_keys
FROM gold.fact_sales
WHERE product_sk IS NULL;

-- Check for missing customer keys in Fact
SELECT COUNT(*) AS missing_customer_keys
FROM gold.fact_sales
WHERE customer_sk IS NULL;
--Check for Duplicate Surrogate Keys:
-- Check for duplicates in Customers
SELECT Customer_rk, COUNT(*) as duplicate_count
FROM gold.dim_customers
GROUP BY Customer_rk
HAVING COUNT(*) > 1;

-- Check for duplicates in Products
SELECT product_sk, COUNT(*) as duplicate_count
FROM gold.dim_products
GROUP BY product_sk
HAVING COUNT(*) > 1;
--Check for Duplicate Business Keys :
-- Check if any Customer ID appears more than once in the Dimension
SELECT Customer_id, COUNT(*) as duplicate_count
FROM gold.dim_customers
GROUP BY Customer_id
HAVING COUNT(*) > 1;

-- Check if any Product Key (prdky) appears more than once in the Dimension
SELECT prdky, COUNT(*) as duplicate_count
FROM gold.dim_products
GROUP BY prdky
HAVING COUNT(*) > 1;
--Check for Invalid Dates in Fact:
SELECT 
    order_number, 
    order_date, 
    ship_date
FROM gold.fact_sales
WHERE ship_date < order_date;
--
