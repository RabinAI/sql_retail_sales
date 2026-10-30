# Retail Sales Analysis with PostgreSQL

An end-to-end SQL project that cleans a retail transactions dataset and answers 10 business questions about sales, customers, product categories, and shopping patterns.

![PostgreSQL](https://img.shields.io/badge/PostgreSQL-316192?style=flat&logo=postgresql&logoColor=white)
![SQL](https://img.shields.io/badge/SQL-Data%20Analysis-blue)
![DBeaver](https://img.shields.io/badge/Tool-DBeaver-orange)

---

## Project Overview

| | |
|---|---|
| **Goal** | Understand sales performance and customer behavior of a retail business |
| **Database** | PostgreSQL |
| **Tool** | DBeaver |
| **Skills shown** | Data cleaning, aggregation, CTEs, window functions, date and time handling, `CASE` logic |

## Objectives

1. Set up a retail sales database and load the data.
2. Clean the data by handling missing values.
3. Explore the data to understand its size and structure.
4. Answer business questions with SQL to support decisions.

---

## Dataset

A retail sales dataset of transactions, with one row per sale.

| Column | Type | Description |
|---|---|---|
| `transactions_id` | INT | Unique transaction ID (primary key) |
| `sale_date` | DATE | Date of the sale |
| `sale_time` | TIME | Time of the sale |
| `customer_id` | INT | Customer identifier |
| `gender` | VARCHAR | Customer gender |
| `age` | INT | Customer age |
| `category` | VARCHAR | Product category (Beauty, Clothing, Electronics) |
| `quantity` | INT | Units sold |
| `price_per_unit` | FLOAT | Price of one unit |
| `cogs` | FLOAT | Cost of goods sold |
| `total_sale` | FLOAT | Total sale amount |

---

## Repository Structure

```
retail-sales-sql-analysis/
├── README.md
├── retail_sales_analysis.sql    # schema, cleaning, and all queries
└── data/
    └── retail_sales.csv         # source data
```

---

## How to Run

1. Install PostgreSQL and DBeaver.
2. Create the database: `CREATE DATABASE sql_project_p2;`
3. Connect DBeaver to `sql_project_p2`.
4. Run the setup section of `retail_sales_analysis.sql` to create the table.
5. Import `data/retail_sales.csv` into `retail_sales` (right-click the table, then **Import Data**).
6. Run the cleaning section, then the business questions.

---

## Data Cleaning

- Checked every column for NULL values.
- Filled missing `age` values with the average age so those sales stayed in the analysis.
- Deleted any remaining rows with missing values in other columns.

```sql
UPDATE retail_sales
SET age = (SELECT ROUND(AVG(age)) FROM retail_sales)
WHERE age IS NULL;
```

> **Note:** filling ages with the average is a simplification. It keeps revenue totals complete but can slightly distort age-based results.

---

## Business Questions and Queries

| # | Question |
|---|---|
| Q1 | All sales made on 2022-11-05 |
| Q2 | Clothing transactions with quantity of 4 or more in November 2022 |
| Q3 | Total sales and order count for each category |
| Q4 | Average age of customers who bought Beauty products |
| Q5 | Transactions where `total_sale` is greater than 1000 |
| Q6 | Number of transactions by gender in each category |
| Q7 | Average sale for each month, and the best-selling month of each year |
| Q8 | Top 5 customers by total sales |
| Q9 | Unique customers per category |
| Q10 | Number of orders in each shift (Morning, Afternoon, Evening) |

### Example: best-selling month of each year

```sql
SELECT year, month, avg_sale
FROM (
    SELECT
        EXTRACT(YEAR FROM sale_date)       AS year,
        EXTRACT(MONTH FROM sale_date)      AS month,
        ROUND(AVG(total_sale)::NUMERIC, 2) AS avg_sale,
        RANK() OVER (
            PARTITION BY EXTRACT(YEAR FROM sale_date)
            ORDER BY AVG(total_sale) DESC
        ) AS rnk
    FROM retail_sales
    GROUP BY 1, 2
) AS monthly_avg
WHERE rnk = 1;
```

### Example: orders by shift

```sql
WITH hourly_sale AS (
    SELECT *,
        CASE
            WHEN EXTRACT(HOUR FROM sale_time) < 12 THEN 'Morning'
            WHEN EXTRACT(HOUR FROM sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
            ELSE 'Evening'
        END AS shift
    FROM retail_sales
)
SELECT shift, COUNT(*) AS total_orders
FROM hourly_sale
GROUP BY shift
ORDER BY total_orders DESC;
```

All queries are in [`retail_sales_analysis.sql`](retail_sales_analysis.sql).

---

## Key Findings

> Replace the placeholders below with your own numbers from the query results.

- **Records:** [X] transactions from [Y] unique customers after cleaning.
- **Top category by revenue:** [category], with [amount] in sales.
- **Best-selling month:** [month] in [year], with an average sale of [amount].
- **Top customers:** the top 5 customers spent between [min] and [max].
- **Busiest shift:** [shift], with [N] orders ([X]% of the total).
- **Customer profile:** Beauty customers average [X] years old.

## Recommendations

1. Focus promotions on **[top category]**, which drives the most revenue.
2. Schedule staff and campaigns around the **[busiest shift]**, when most orders happen.
3. Reward the **top customers** with a loyalty offer to keep their spending.

---

## Limitations

- Average-age imputation was used for missing ages.
- The dataset covers a limited period, so results may not reflect seasonal patterns.
- No profit analysis was done. A natural next step is using `cogs` to compute profit by category.

## Next Steps

- Add profit and margin analysis using `cogs`.
- Build a Power BI or Tableau dashboard from these query results.
- Repeat the analysis in Python with pandas to compare approaches.

---

## Author

Rabin Khadka
[LinkedIn](https://www.linkedin.com/in/rabin-khadka-7a1963261/) | [GitHub](https://github.com/RabinAI)
