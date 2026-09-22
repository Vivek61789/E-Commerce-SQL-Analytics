USE ecommerce_analytics;

-- Generate a sequence of numbers from 1 to 10
WITH RECURSIVE number_sequence AS (
    SELECT 1 AS number

    UNION ALL

    SELECT number + 1
    FROM number_sequence
    WHERE number < 10
)
SELECT number
FROM number_sequence;

-- Generate dates for the first ten days of July 2024
WITH RECURSIVE date_sequence AS (
    SELECT DATE('2024-07-01') AS report_date

    UNION ALL

    SELECT DATE_ADD(report_date, INTERVAL 1 DAY)
    FROM date_sequence
    WHERE report_date < '2024-07-10'
)
SELECT report_date
FROM date_sequence;

-- Generate a complete monthly calendar for July 2024
WITH RECURSIVE calendar AS (
    SELECT DATE('2024-07-01') AS calendar_date

    UNION ALL

    SELECT DATE_ADD(calendar_date, INTERVAL 1 DAY)
    FROM calendar
    WHERE calendar_date < '2024-07-31'
)
SELECT
    calendar_date,
    DAYNAME(calendar_date) AS day_name,
    DAYOFWEEK(calendar_date) AS day_number
FROM calendar;

-- Generate monthly dates for the first six months of 2024
WITH RECURSIVE month_sequence AS (
    SELECT DATE('2024-01-01') AS month_start

    UNION ALL

    SELECT DATE_ADD(month_start, INTERVAL 1 MONTH)
    FROM month_sequence
    WHERE month_start < '2024-06-01'
)
SELECT
    month_start,
    YEAR(month_start) AS year_number,
    MONTH(month_start) AS month_number,
    MONTHNAME(month_start) AS month_name
FROM month_sequence;

-- Generate daily sales dates and show orders placed on each date
WITH RECURSIVE sales_calendar AS (
    SELECT DATE('2024-06-15') AS sales_date

    UNION ALL

    SELECT DATE_ADD(sales_date, INTERVAL 1 DAY)
    FROM sales_calendar
    WHERE sales_date < '2024-07-15'
)
SELECT
    sc.sales_date,
    COUNT(o.order_id) AS total_orders,
    COALESCE(SUM(o.total_amount), 0) AS daily_revenue
FROM sales_calendar sc
LEFT JOIN orders o
    ON DATE(o.order_date) = sc.sales_date
GROUP BY sc.sales_date
ORDER BY sc.sales_date;

-- Generate a five-level quantity sequence for analysis
WITH RECURSIVE quantity_levels AS (
    SELECT 1 AS quantity_level

    UNION ALL

    SELECT quantity_level + 1
    FROM quantity_levels
    WHERE quantity_level < 5
)
SELECT quantity_level
FROM quantity_levels;

-- Generate price ranges for product analysis
WITH RECURSIVE price_ranges AS (
    SELECT 0 AS minimum_price, 999 AS maximum_price

    UNION ALL

    SELECT
        maximum_price + 1,
        maximum_price + 1000
    FROM price_ranges
    WHERE maximum_price < 4999
)
SELECT
    minimum_price,
    maximum_price,
    (
        SELECT COUNT(*)
        FROM products p
        WHERE p.price BETWEEN minimum_price AND maximum_price
    ) AS product_count
FROM price_ranges;

-- Generate the first seven days after each order date
WITH RECURSIVE order_followup AS (
    SELECT
        order_id,
        DATE(order_date) AS followup_date,
        0 AS day_number
    FROM orders

    UNION ALL

    SELECT
        order_id,
        DATE_ADD(followup_date, INTERVAL 1 DAY),
        day_number + 1
    FROM order_followup
    WHERE day_number < 6
)
SELECT
    order_id,
    followup_date,
    day_number
FROM order_followup
ORDER BY order_id, followup_date;

-- Generate a sequence for testing cumulative calculations
WITH RECURSIVE sequence AS (
    SELECT 1 AS number, 1 AS running_total

    UNION ALL

    SELECT
        number + 1,
        running_total + number + 1
    FROM sequence
    WHERE number < 10
)
SELECT
    number,
    running_total
FROM sequence;

-- Generate weekly reporting dates
WITH RECURSIVE weekly_dates AS (
    SELECT DATE('2024-06-01') AS week_start

    UNION ALL

    SELECT DATE_ADD(week_start, INTERVAL 7 DAY)
    FROM weekly_dates
    WHERE week_start < '2024-07-01'
)
SELECT
    week_start,
    DATE_ADD(week_start, INTERVAL 6 DAY) AS week_end
FROM weekly_dates;