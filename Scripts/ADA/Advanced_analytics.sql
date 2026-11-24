/* ============================================================
   Advanced Analytics — Window Functions on Gold Star Schema
   ------------------------------------------------------------
   1. Purpose: demonstrates advanced SQL window functions
      (OVER, PARTITION BY, ROWS BETWEEN, LAG) directly on the
      gold.fact_sales ↔ gold.dim_products join — the kind of
      analytics typically done in BI tools or reporting layers.
   2. Change-over-time: yearly totals and monthly averages
      computed per row (no GROUP BY needed) via PARTITION BY
      YEAR/MONTH — keeps transaction detail intact.
   3. Cumulative analysis: running total from the first sale
      (ROWS UNBOUNDED PRECEDING) and a 3-row moving average
      (ROWS BETWEEN 2 PRECEDING AND CURRENT ROW).
   4. Performance analysis: each sale compared to overall
      average, lowest sale, and previous transaction (LAG).
   5. Part-to-whole: each row's % of total company revenue and
      % of its category's revenue — useful for contribution
      analysis without pre-aggregation.
   6. Data segmentation: buckets sales into Low/Medium/High
      and products into Free/Low/High cost via CASE.
   7. Uses LEFT JOIN so facts without a product match still
      appear (category/cost will be NULL — worth noting).
   8. Filters out the known bad date (5489) with
      `order_date <= '2024-12-31'` — same guard as EDA file.
   9. Read-only SELECT — safe to run repeatedly; no data
      modification. Intended as a demo/reference of window
      function patterns, not part of the ETL pipeline.
  10. Note: output is row-level (one row per sale), not
      aggregated — suitable for downstream pivot/charting.
   ============================================================ */
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
