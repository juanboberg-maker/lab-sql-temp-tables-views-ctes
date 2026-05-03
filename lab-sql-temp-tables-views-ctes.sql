USE sakila;

-- Step 1: Create a view with rental summary per customer
CREATE OR REPLACE VIEW customer_rental_summary AS
SELECT
    c.customer_id,
    CONCAT(c.first_name, ' ', c.last_name) AS customer_name,
    c.email,
    COUNT(r.rental_id) AS rental_count
FROM customer c
LEFT JOIN rental r
    ON c.customer_id = r.customer_id
GROUP BY
    c.customer_id,
    c.first_name,
    c.last_name,
    c.email;

-- Step 2: Create a temporary table with total paid per customer
CREATE TEMPORARY TABLE customer_payment_summary AS
SELECT
    crs.customer_id,
    COALESCE(SUM(p.amount), 0) AS total_paid
FROM customer_rental_summary crs
LEFT JOIN rental r
    ON crs.customer_id = r.customer_id
LEFT JOIN payment p
    ON r.rental_id = p.rental_id
GROUP BY
    crs.customer_id;

-- Step 3: Create a CTE and final customer summary report
WITH customer_summary_cte AS (
    SELECT
        crs.customer_name,
        crs.email,
        crs.rental_count,
        cps.total_paid
    FROM customer_rental_summary crs
    JOIN customer_payment_summary cps
        ON crs.customer_id = cps.customer_id
)
SELECT
    customer_name,
    email,
    rental_count,
    total_paid,
    ROUND(total_paid / NULLIF(rental_count, 0), 2) AS average_payment_per_rental
FROM customer_summary_cte
ORDER BY customer_name;