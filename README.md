🏢 Modern Data Warehouse & Analytics Project (SQL Server)
📖 Project Overview
This project demonstrates the end-to-end development of a modern Data Warehouse using Microsoft SQL Server. It encompasses the complete ETL (Extract, Transform, Load) lifecycle—from ingesting raw data from multiple source systems (CRM and ERP) to building a robust, business-ready dimensional model optimized for analytical reporting and business intelligence (BI).

The architecture follows the Medallion Architecture (Bronze, Silver, Gold), ensuring data quality, traceability, and optimal performance.

🏗️ Data Architecture (Medallion Pipeline)
The project is structured in three progressive layers:

🥉 Bronze Layer (Raw Data):

Extracts raw CSV data from source systems (CRM and ERP) into SQL Server.

Data is stored exactly as it was received (no transformations) to maintain historical integrity.

🥈 Silver Layer (Cleaned & Standardized):

Cleanses, trims, and standardizes the data.

Handles data quality issues (e.g., removing duplicates, fixing NULLs, negative values, correcting invalid dates).

Applies business rules (e.g., translating M/F to Male/Female, mapping country codes, splitting product keys).

Integrates ERP and CRM data using standardized business keys.

🥇 Gold Layer (Business-Ready):

Models the data into a Star Schema (Dimension and Fact tables).

Generates surrogate keys (Primary Keys) and enforces Foreign Key relationships.

Optimized for direct consumption by BI tools (Power BI) and analytical queries.

🔄 Data Flow & Source Relations
Sources
CRM System: Contains customer master data, product details, and sales transactions.

ERP System: Contains demographic data (gender, birthdate), location data (country), and product category hierarchies.

Entity Relationships
The initial extraction joins CRM and ERP tables using specific logic (e.g., stripping NAS prefixes and hyphens from ERP keys to match CRM business keys), which is later standardized in the Silver layer.

🧮 Data Modeling (Gold Layer)
The Gold layer is designed using a Star Schema, allowing for fast aggregation and intuitive querying.

📌 Fact Table: gold.fact_sales
The central transactional table storing key sales metrics.

Grain: One row per sales order line.

Measures: quantity, price, sales_amount.

Foreign Keys: Links to Dim_Customers and Dim_Products.

📌 Dimension Tables
gold.dim_customers: Consolidated CRM and ERP customer data. Includes standardized gender, marital status, country, and birthdate.

gold.dim_products: Consolidated product and category data. Includes extracted category IDs, product names, lines, and historical start/end dates.
.

📊 Analytics & Insights
To validate the data model and extract business value, two distinct analytical scripts are included in the repository:

1. Exploratory Data Analysis (EDA)
Designed to profile the Gold layer and validate data quality. It includes:

Entity Profiling: Checking distinct categories, demographics, and quantities to spot unexpected values.

Date Exploration: Finding min/max order dates, shipping lead times, customer age ranges, and product lifespans.

Measure Exploration: Profiling min/max/avg of sales, checking for negative revenue, and calculating Average Order Value (AOV).

Business KPIs: Time-series analysis (revenue by year/month), sales by product category, and Top 10 customers by spend.

2. Advanced Analytics (Window Functions)
Demonstrates advanced SQL capabilities directly on the Star Schema without needing to pre-aggregate in BI tools. It includes:

Change-over-Time: Yearly and monthly aggregations alongside row-level detail using PARTITION BY.

Cumulative Analysis: Running totals (ROWS UNBOUNDED PRECEDING) and 3-row moving averages (ROWS BETWEEN 2 PRECEDING AND CURRENT ROW).

Performance Analysis: Comparing each transaction to the overall average, minimum sale, and previous transaction using LAG().

Part-to-Whole: Calculating the percentage contribution of each row to total company revenue and category revenue.

Data Segmentation: Bucketing sales into Low/Medium/High and products into Free/Low/High cost using CASE statements.



More information:
-
LINKEDIN:https://www.linkedin.com/in/zaid-oualaarbi-9b8b693b4/
-
GITHUB:ozaid2268-cpu
-
GMAIL:ozaid2268@gmail.com
-
