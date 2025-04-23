--  Basic data exploration on the dataset

SELECT 
	order_id, customer_id, order_status, order_purchase_timestamp
FROM
	ecommerce.ecomm_order_details
LIMIT 10;


-- Finding the top 10 results from a query or results within a certain timespan. 

SELECT
	order_id, SUM(payment_value)
FROM 
    ecommerce.ecomm_payments
GROUP BY order_id
ORDER BY SUM(payment_value)

LIMIT 10;


-- Combine two tables to create a single outcome.

SELECT
	ecomm_orders.order_id,
    ecomm_orders.order_items,
  	ecomm_order_details.order_status,
    ecomm_order_details.order_purchase_timestamp
FROM
	ecommerce.ecomm_orders
JOIN 
	ecommerce.ecomm_order_details USING(order_id)

ORDER BY order_purchase_timestamp DESC
LIMIT 10;

-- Query a timestamp from our orders dataset.

SELECT

	COUNT(order_id)
FROM
	ecommerce.ecomm_order_details

WHERE EXTRACT(QUARTER from order_purchase_timestamp) = 4
AND EXTRACT(YEAR from order_purchase_timestamp) = 2017

-- Formatting timestamps and dates

SELECT

	FORMAT_TIMESTAMP('%D',order_purchase_timestamp) AS order_date,
    order_id
FROM 
	ecommerce.ecomm_order_details
LIMIT 3;

-- Finding data within certain ranges. Finding results within a certain range of a specific date (e.g., Black Friday for e-commerce) or between two dates 

SELECT
	count(order_id)
FROM 
	ecommerce.ecomm_order_details

WHERE order_purchase_timestamp BETWEEN
	TIMESTAMP_SUB(TIMESTAMP('2017-11-24'), INTERVAL 3 DAY) 
    AND TIMESTAMP_ADD(TIMESTAMP('2017-11-24'), INTERVAL 3 DAY)

--  Using CURRENT_TIMESTAMP. Another common question in analytical queries is finding data within a certain interval of the current date or time.

SELECT

	DATE_DIFF(
      EXTRACT(DATE FROM order_purchase_timestamp),
      CURRENT_DATE(),
      DAY
    )
FROM 
	ecommerce.ecomm_order_details
LIMIT 5;

-- Create an array in a query

SELECT
	ARRAY(SELECT 

          	product_id 
          FROM 
          	ecommerce.ecomm_products
          WHERE
         	product_weight_g = 2220)


-- Use SEARCH with unstructured data
SELECT 
	SEARCH(order_items,'0da9ffd92214425d880de3f94e74ce39') as results   
FROM ecommerce.ecomm_orders
LIMIT 5



-- UNNEST-ing Data. Accessing the data inside those queries will help you create a lot of value from that data and use it to connect to other tables. 

SELECT
	order_id, items.price
FROM 
	ecommerce.ecomm_orders,
    UNNEST(order_items) items
WHERE order_id = 'a0e747c954a595b0e3458c87ab1a4958';



--  Filtering data with CTEs: Find the order status of orders with items that have a price over $150.

WITH orders AS (
  SELECT order_id
  FROM ecommerce.ecomm_orders, UNNEST(order_items) items
  WHERE items.price > 150
)

SELECT
	COUNT(order_id),
	order_status
FROM ecommerce.ecomm_order_details
JOIN orders o USING (order_id)
GROUP BY order_status


-- Optimizing using CTEs: Find the highest number of payments by order item count.

WITH payments AS (
  SELECT
    MAX(payment_sequential) AS num_payments,
    order_id
  FROM ecommerce.ecomm_payments 
  GROUP BY order_id)
     
SELECT
  ARRAY_LENGTH(o.order_items) AS num_items,
  MAX(p.num_payments) AS max_payments
FROM ecommerce.ecomm_orders o
JOIN payments p
USING (order_id)
GROUP BY ARRAY_LENGTH(o.order_items)

-- Using multiple CTEs. split a query into two CTEs to make it easier to read and more performant.

WITH orders AS (
SELECT order_id, items.product_id, items.price
FROM ecommerce.ecomm_orders o, UNNEST(order_items) items 
WHERE items.price > 100
),

products AS (
SELECT product_id,
AVG(product_weight_g) as avg_weight
FROM ecommerce.ecomm_products
GROUP BY product_id
)

SELECT
	o.order_id,
	p.avg_weight
FROM orders o
JOIN products p ON p.product_id = o.product_id;

-- Using COUNTIF. count all the products over a specific weight and group them by category.

SELECT
  product_category_name_english,
  COUNTIF(product_weight_g > 5000)
FROM ecommerce.ecomm_products

GROUP BY product_category_name_english; 

-- Filtering with HAVING. find all the product categories that have an average weight over a certain amount to find the categories that might incur higher shipping costs due to weight.

SELECT
    product_category_name_english, 
    AVG(product_weight_g)
FROM ecommerce.ecomm_products
GROUP BY product_category_name_english
HAVING AVG(product_weight_g) > 10000

-- ANY_VALUE. ANY_VALUE aggregate that allows you to return a value from a text column. You can use this in combination with HAVING to find a maximum or minimum value.

SELECT
  product_weight_g,
	ANY_VALUE(product_category_name_english HAVING MAX(product_photos_qty)) AS random_product
FROM ecommerce.ecomm_products
GROUP BY product_weight_g;

-- Logical aggregates. ook at groups of data to see if they have been delivered or if at least one of the values has been delivered.

SELECT
  customer_id,
  LOGICAL_AND(order_status = "delivered") as all_delivered
FROM ecommerce.ecomm_order_details
GROUP BY customer_id;

-- Using STRING_AGG and ARRAY_CONCAT_AGG
SELECT
    o.order_id,  
    STRING_AGG(DISTINCT product_category_name_english, ",") AS categories
FROM
    ecommerce.ecomm_orders o, UNNEST(order_items) items
JOIN
    ecommerce.ecomm_products p ON items.product_id = p.product_id
WHERE ARRAY_LENGTH(o.order_items) > 1
GROUP BY
    order_id

-- Approximate statistical functions.GoogleSQL provides four different approximate aggregate functions which provide better performance on large datasets: APPROX_COUNT_DISTINCT, APPROX_QUANTILES, APPROX_TOP_COUNT, APPROX_TOP_SUM. 

SELECT
  items.product_id,
  APPROX_COUNT_DISTINCT(customer_id) AS estimated_unique_customers
FROM ecommerce.ecomm_orders o, UNNEST(o.order_items) items
JOIN ecommerce.ecomm_order_details od USING (order_id)
GROUP BY items.product_id;


-- RANK and LEAD/LAG 

SELECT
  od.customer_id,
  items.price, 
  LAG(items.price) OVER(
    PARTITION BY od.customer_id 
    ORDER BY od.order_purchase_timestamp) as lag,
  LEAD(items.price) OVER(
    PARTITION BY od.customer_id 
    ORDER BY od.order_purchase_timestamp) as lead,
FROM ecommerce.ecomm_orders o, UNNEST(o.order_items) items
JOIN ecommerce.ecomm_order_details od USING (order_id)
WHERE ARRAY_LENGTH(o.order_items) < 4
ORDER BY ARRAY_LENGTH(o.order_items) DESC;


-- Using row based WINDOW functions. create a row based window function.

SELECT
  order_id,
  order_purchase_timestamp,
  AVG(price) 
  OVER(
    ORDER BY order_purchase_timestamp 
    ROWS BETWEEN
    9 PRECEDING
    AND CURRENT ROW) as rolling_avg
FROM ecommerce.ecomm_order_details od
JOIN ecommerce.ecomm_orders o 
USING (order_id), unnest(o.order_items) as item
ORDER BY order_purchase_timestamp;

-- Filtering with QUALIFY. Times when the rolling average of the current and previous 9 rows averaged over $500.

SELECT
  order_id,
  order_purchase_timestamp,
  AVG(item.price) 
  OVER(ORDER BY order_purchase_timestamp 
       ROWS BETWEEN 9 PRECEDING AND CURRENT ROW) as rolling_avg
FROM ecommerce.ecomm_order_details od
JOIN ecommerce.ecomm_orders o 
USING (order_id), unnest(o.order_items) as item
QUALIFY rolling_avg > 500
ORDER BY order_purchase_timestamp;

-- RIGHT, LEFT, and OUTER joins

WITH orders AS (
  SELECT order_id, item.product_id
  FROM ecommerce.ecomm_orders, UNNEST(order_items) item
  LIMIT 10
),
products AS (
  SELECT product_id
  FROM ecommerce.ecomm_products
  LIMIT 10000
)
SELECT
	COUNT(*) AS orders
FROM orders o
LEFT JOIN products p ON p.product_id = o.product_id;

-- UNNEST with CROSS JOINs

SELECT
	o.order_id,
	item.price
FROM ecommerce.ecomm_orders o
CROSS JOIN UNNEST(o.order_items) item

-- Joins with aggregations. Count the number of orders per product.

WITH orders AS (SELECT
o.order_id,
item.product_id
FROM ecommerce.ecomm_orders o, unnest(o.order_items) item)

SELECT 
	p.product_id,
	COUNT(o.order_id)
FROM orders o
INNER JOIN ecommerce.ecomm_products p
USING(product_id)
GROUP BY p.product_id;

-- Finding the last 90 days of orders

SELECT order_id, order_purchase_timestamp 
FROM ecommerce.ecomm_order_details
WHERE order_purchase_timestamp <= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY)


-- Perform optimizations in BigQuery. FInd the number of customers using a payment plan. Grouped by the number of payment installments. The average payment per installment for each group


SELECT
	p.payment_installments,
	COUNT(p.order_id)                      
FROM ecommerce.ecomm_payments p
JOIN ecommerce.ecomm_order_details o USING (order_id)
GROUP BY p.payment_installments
































