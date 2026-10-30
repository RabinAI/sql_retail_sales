-- =====================================================================
--  RETAIL SALES ANALYSIS  |  PostgreSQL
-- =====================================================================
--  Database : sql_project_p2
--  Table    : retail_sales
--  Purpose  : Clean a retail transactions dataset and answer business
--             questions about sales, customers, categories, and
--             shopping patterns.
--
--  Sections : 1. Setup
--             2. Data Exploration
--             3. Data Cleaning
--             4. Business Questions (Q1 - Q10)
-- =====================================================================


-- =====================================================================
-- 1. SETUP
-- =====================================================================
-- Run this line on its own, then connect to the new database
-- before running the rest of the script.
-- CREATE DATABASE sql_project_p2;

DROP TABLE IF EXISTS retail_sales;

CREATE TABLE retail_sales (
    transactions_id INT PRIMARY KEY,
    sale_date       DATE,
    sale_time       TIME,
    customer_id     INT,
    gender          VARCHAR(25),
    age             INT,
    category        VARCHAR(15),
    quantity        INT,
    price_per_unit  FLOAT,
    cogs            FLOAT,
    total_sale      FLOAT
);

-- Import data/retail_sales.csv into this table
-- (DBeaver: right-click table > Import Data), then run the checks below.


-- =====================================================================
-- 2. DATA EXPLORATION
-- =====================================================================

-- Total number of records
SELECT COUNT(*) AS total_records
FROM retail_sales;

-- Number of unique customers
SELECT COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales;

-- Product categories available
SELECT DISTINCT category
FROM retail_sales;


-- =====================================================================
-- 3. DATA CLEANING
-- =====================================================================

-- 3.1 Find rows with a missing value in any column
SELECT *
FROM retail_sales
WHERE transactions_id IS NULL
   OR sale_date       IS NULL
   OR sale_time       IS NULL
   OR customer_id     IS NULL
   OR gender          IS NULL
   OR age             IS NULL
   OR category        IS NULL
   OR quantity        IS NULL
   OR price_per_unit  IS NULL
   OR cogs            IS NULL
   OR total_sale      IS NULL;

-- 3.2 Missing ages: fill with the average age so those sales are kept
UPDATE retail_sales
SET age = (SELECT ROUND(AVG(age)) FROM retail_sales)
WHERE age IS NULL;

-- 3.3 Delete any remaining incomplete rows
DELETE FROM retail_sales
WHERE transactions_id IS NULL
   OR sale_date       IS NULL
   OR sale_time       IS NULL
   OR customer_id     IS NULL
   OR gender          IS NULL
   OR age             IS NULL
   OR category        IS NULL
   OR quantity        IS NULL
   OR price_per_unit  IS NULL
   OR cogs            IS NULL
   OR total_sale      IS NULL;

-- 3.4 Confirm the final row count
SELECT COUNT(*) AS records_after_cleaning
FROM retail_sales;


-- =====================================================================
-- 4. BUSINESS QUESTIONS
-- =====================================================================

-- Q1. Retrieve all columns for sales made on 2022-11-05
SELECT *
FROM retail_sales
WHERE sale_date = '2022-11-05';


-- Q2. Retrieve all Clothing transactions with a quantity of 4 or more
--     in November 2022
SELECT *
FROM retail_sales
WHERE category = 'Clothing'
  AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'
  AND quantity >= 4;


-- Q3. Calculate total sales and number of orders for each category
SELECT
    category,
    SUM(total_sale) AS net_sales,
    COUNT(*)        AS total_orders
FROM retail_sales
GROUP BY category
ORDER BY net_sales DESC;


-- Q4. Find the average age of customers who purchased from the Beauty category
SELECT ROUND(AVG(age)) AS avg_age
FROM retail_sales
WHERE category = 'Beauty';


-- Q5. Find all transactions where total_sale is greater than 1000
SELECT *
FROM retail_sales
WHERE total_sale > 1000;


-- Q6. Find the number of transactions made by each gender in each category
SELECT
    category,
    gender,
    COUNT(*) AS total_transactions
FROM retail_sales
GROUP BY category, gender
ORDER BY category, gender;


-- Q7. Calculate the average sale for each month, then find the
--     best-selling month in each year
SELECT year, month, avg_sale
FROM (
    SELECT
        EXTRACT(YEAR FROM sale_date)         AS year,
        EXTRACT(MONTH FROM sale_date)        AS month,
        ROUND(AVG(total_sale)::NUMERIC, 2)   AS avg_sale,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM sale_date)
            ORDER BY AVG(total_sale) DESC
        ) AS rnk
    FROM retail_sales
    GROUP BY 1, 2
) AS monthly_avg
WHERE rnk = 1;


-- Q8. Find the top 5 customers by total sales
SELECT
    customer_id,
    SUM(total_sale) AS total_spent
FROM retail_sales
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 5;


-- Q9. Find the number of unique customers who purchased from each category
SELECT
    category,
    COUNT(DISTINCT customer_id) AS unique_customers
FROM retail_sales
GROUP BY category
ORDER BY unique_customers DESC;


-- Q10. Create shifts and count orders in each
--      Morning: before 12:00 | Afternoon: 12:00 - 17:59 | Evening: 18:00 onward
WITH hourly_sale AS (
    SELECT *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT
    shift,
    COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift
ORDER BY total_orders DESC;


-- =====================================================================
-- END OF PROJECT
-- =====================================================================