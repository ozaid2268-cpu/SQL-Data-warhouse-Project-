SELECT 
    -- Base Columns (The Transaction details)
    f.order_number,
    f.order_date,
    p.category,
    f.sales_amount,
    
    -- =================================================================
    -- 1. CHANGE-OVER-TIME TRENDS
    -- (Simulating Yearly Aggregation without GROUP BY)
    -- =================================================================
    YEAR(f.order_date) AS Order_Year,
    -- This sums up all sales for that specific year and attaches it to every row
    SUM(f.sales_amount) OVER (PARTITION BY YEAR(f.order_date)) AS Total_Sales_For_This_Year,
    -- Average cost per month
    AVG(f.sales_amount) OVER (PARTITION BY YEAR(f.order_date), MONTH(f.order_date)) AS Avg_Sales_For_This_Month,

    -- =================================================================
    -- 2. CUMULATIVE ANALYSIS
    -- =================================================================
    -- Running total of sales from the very first day to the current row
    SUM(f.sales_amount) OVER (
        ORDER BY f.order_date, f.order_number 
        ROWS UNBOUNDED PRECEDING
    ) AS Running_Total_Sales,
    
    -- Moving average of the last 3 rows (simulating 3-month moving average)
    AVG(f.sales_amount) OVER (
        ORDER BY f.order_date, f.order_number 
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS Moving_Avg_Last_3_Sales,

    -- =================================================================
    -- 3. PERFORMANCE ANALYSIS
    -- =================================================================
    -- Current Sales vs Overall Average Sales
    f.sales_amount - AVG(f.sales_amount) OVER () AS Diff_From_Overall_Avg,
    
    -- Current Sales vs the Lowest Sale in the entire table
    f.sales_amount - MIN(f.sales_amount) OVER () AS Diff_From_Lowest_Sale,
    
    -- Current Sale vs Previous Sale (Year-over-Year substitute for row-level)
    f.sales_amount - LAG(f.sales_amount, 1) OVER (ORDER BY f.order_date, f.order_number) AS Diff_From_Previous_Transaction,

    -- =================================================================
    -- 4. PART-TO-WHOLE ANALYSIS
    -- =================================================================
    -- What % of TOTAL company revenue is this specific row?
    CAST((f.sales_amount * 100.0) / SUM(f.sales_amount) OVER () AS DECIMAL(10,2)) AS Pct_Of_Total_Company_Sales,
    
    -- What % of that specific CATEGORY's revenue is this specific row?
    CAST((f.sales_amount * 100.0) / SUM(f.sales_amount) OVER (PARTITION BY p.category) AS DECIMAL(10,2)) AS Pct_Of_Category_Sales,

    -- =================================================================
    -- 5. DATA SEGMENTATION
    -- =================================================================
    -- Categorizing the specific sales amount
    CASE 
        WHEN f.sales_amount < 500 THEN 'Low Sale'
        WHEN f.sales_amount BETWEEN 500 AND 2000 THEN 'Medium Sale'
        WHEN f.sales_amount > 2000 THEN 'High Sale'
    END AS Sales_Amount_Segment,

    -- Categorizing the product cost
    CASE
        WHEN p.cost = 0 THEN 'Free/No Cost'
        WHEN p.cost < 100 THEN 'Low Cost Product'
        WHEN p.cost >= 100 THEN 'High Cost Product'
    END AS Product_Cost_Segment

FROM gold.fact_sales f
LEFT JOIN gold.dim_products p ON f.product_sk = p.product_sk
-- Filtering out the 5489 error date you found earlier!
WHERE f.order_date <= '2024-12-31' 
ORDER BY f.order_date, f.order_number;
