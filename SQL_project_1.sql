-- Select all rows from the table (optional initial check)
SELECT *
FROM walmart;

-- Count total number of rows
SELECT COUNT(*) AS total_rows
FROM walmart;

-- Count number of orders per branch
SELECT 
    branch,
    COUNT(*) AS branch_orders
FROM walmart
GROUP BY branch;

-- Find minimum quantity sold in any order
SELECT MIN(quantity) AS min_quantity
FROM walmart;

-- Count number of orders per payment method
SELECT 
    payment_method,
    COUNT(*) AS total_orders
FROM walmart
GROUP BY payment_method;

-- Q.1
-- Get payment method stats: number of payments and total quantity sold
SELECT
    payment_method,
    COUNT(*) AS no_payments,
    SUM(quantity) AS no_qty_sold
FROM walmart
GROUP BY payment_method;



-- Project Question #2
-- Identify the highest-rated category in each branch
-- Show branch, category, avg_rating, and rank

SELECT branch, category, avg_rating, rank_no
FROM (
    SELECT
        branch,
        category,
        AVG(rating) AS avg_rating,
        RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS rank_no
    FROM walmart
    GROUP BY branch, category
) AS ranked
WHERE rank_no = 1
ORDER BY branch;

-- Q.3 Identify the busiest day for each branch based on the number of transactions

SELECT branch, day_name, no_transactions, rank_no
FROM (
    SELECT 
        branch,
        DAYNAME(STR_TO_DATE(date, '%d/%m/%y')) AS day_name,
        COUNT(*) AS no_transactions,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank_no
    FROM walmart
    GROUP BY branch, day_name
) AS ranked
WHERE rank_no = 1;

-- Q.4
-- Calculate the total quantity of items sold per payment method. List payment_method and total_quantity
SELECT
  payment_method,
  -- COUNT(*) as no_payments,
  SUM(quantity) as no_qty_sold
FROM walmart
GROUP BY payment_method;

-- Q.5
-- Determine the average, minimum, and maximum rating of products for each city.
-- List the city, average_rating, min_rating, and max_rating.
SELECT
  city,
  category,
  MIN(rating) AS min_rating,
  MAX(rating) AS max_rating,
  AVG(rating) AS avg_rating
FROM walmart
GROUP BY city, category;

-- Q.6
-- Calculate the total profit for each by considering total_profit as
-- (unit_price * profit_margin). List category and total_profit, ordered from highest to lowest profit
SELECT
  category,
  SUM(total) AS total_revenue,
  SUM(total * profit_margin) AS profit
FROM walmart
GROUP BY category;





-- Q.7
-- Determine the most common payment method for each Branch
-- Display Branch and the preferred_payment_method
WITH cte AS (
    SELECT
        branch,
        payment_method,
        COUNT(*) AS total_trans,
        RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS rank_no
    FROM walmart
    GROUP BY branch, payment_method
)
SELECT *
FROM cte
WHERE rank_no = 1;





-- Q.8
-- Categorize sales into 3 group MORNING, AFTERNOON, EVENING
-- Find out each of the shift and number of invoices

SELECT
  branch,
  CASE
    WHEN EXTRACT(HOUR FROM time) < 12 THEN 'Morning'
    WHEN EXTRACT(HOUR FROM time) BETWEEN 12 AND 17 THEN 'Afternoon'
    ELSE 'Evening'
  END AS day_time,
  COUNT(*) AS count
FROM walmart
GROUP BY branch, day_time
ORDER BY branch, count DESC;





#9
-- Identify 5 branche with highest decrease ratio in
-- revevenue compare to last year(current year 2023 and last year 2022)

WITH revenue_2022 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT
        branch,
        SUM(total) AS revenue
    FROM walmart
    WHERE YEAR(STR_TO_DATE(date, '%d/%m/%y')) = 2023
    GROUP BY branch
)

SELECT
    ls.branch,
    ls.revenue AS last_year_revenue,
    cs.revenue AS cr_year_revenue,
    ROUND(
        ((ls.revenue - cs.revenue) / ls.revenue) * 100,
        2
    ) AS rev_dec_ratio
FROM revenue_2022 AS ls
JOIN revenue_2023 AS cs ON ls.branch = cs.branch
WHERE ls.revenue > cs.revenue
ORDER BY rev_dec_ratio DESC
LIMIT 5;





USE walmart_db;

-- 1️⃣ Count distinct branches
SELECT COUNT(DISTINCT Branch) AS total_branches
FROM walmart;

-- 2️⃣ Number of items sold for each payment method
SELECT payment_method,
       COUNT(*) AS no_of_payments,
       SUM(quantity) AS no_of_items_sold
FROM walmart
GROUP BY payment_method;

-- 3️⃣ Highest-rated category in every branch (with average rating)
-- Approach 1: Simple aggregation
SELECT DISTINCT branch, category,
       MAX(rating) AS max_rating,
       AVG(rating) AS avg_rating
FROM walmart
GROUP BY branch, category
ORDER BY branch, avg_rating DESC;

-- Approach 2: Using RANK for precise ranking
SELECT branch,
       RANK() OVER (PARTITION BY branch ORDER BY AVG(rating) DESC) AS ranking,
       category,
       AVG(rating) AS avg_rating
FROM walmart
GROUP BY branch, category
ORDER BY branch;

-- 4️⃣ Identify busiest day for each branch (based on number of transactions)
SELECT *
FROM (
    SELECT branch, 
           DAYNAME(date) AS day_name,
           COUNT(*) AS no_of_transactions,
           RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
    FROM walmart
    GROUP BY branch, day_name
    ORDER BY branch, DAYOFWEEK(date)
) AS busiest_days
WHERE ranking = 1;

-- 5️⃣ Average, minimum, and maximum ratings of products for each city and category
SELECT city, category,
       AVG(rating) AS avg_rating,
       MIN(rating) AS min_rating,
       MAX(rating) AS max_rating
FROM walmart
GROUP BY city, category;

-- 6️⃣ Total profit per category 
-- Formula: total_profit = total * profit_margin
SELECT category,
       SUM(total * profit_margin) AS total_price
FROM walmart
GROUP BY category
ORDER BY total_price DESC;

-- 7️⃣ Most common payment method for each branch
SELECT *
FROM (
    SELECT branch, payment_method,
           COUNT(*) AS total_trans,
           RANK() OVER (PARTITION BY branch ORDER BY COUNT(*) DESC) AS ranking
    FROM walmart
    GROUP BY branch, payment_method
) AS t
WHERE ranking = 1;

-- 8️⃣ Categorize sales into Morning, Afternoon, and Evening shifts
SELECT CASE 
           WHEN HOUR(time) < 12 THEN 'Morning'
           WHEN HOUR(time) BETWEEN 12 AND 17 THEN 'Afternoon'
           ELSE 'Evening'
       END AS time_day,
       COUNT(*) AS no_of_invoices
FROM walmart
GROUP BY time_day;

-- 9️⃣ Total profit per branch
SELECT branch,
       SUM(total_profit) AS total_profit
FROM walmart
GROUP BY branch
ORDER BY total_profit DESC;

-- 🔟 Top 5 categories by total profit in each branch
SELECT branch, category,
       SUM(total_profit) AS total_profit
FROM walmart
GROUP BY branch, category
ORDER BY branch, total_profit DESC
LIMIT 5;

-- 1️⃣1️⃣ Cumulative profit trend by date
SELECT date,
       SUM(total_profit) OVER (ORDER BY date) AS cumulative_profit
FROM walmart
ORDER BY date;

-- 1️⃣2️⃣ Day of the week with the highest average profit per branch
SELECT branch,
       DAYNAME(date) AS day_name,
       AVG(total_profit) AS avg_profit
FROM walmart
GROUP BY branch, day_name
ORDER BY branch, avg_profit DESC;
-- 1️⃣3️⃣ Profit category distribution
SELECT profit_category,
       COUNT(*) AS transaction_count,
       SUM(total_profit) AS total_profit
FROM walmart
GROUP BY profit_category
ORDER BY total_profit DESC;