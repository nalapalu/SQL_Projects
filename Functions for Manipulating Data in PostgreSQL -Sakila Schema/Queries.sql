--EDA 
SELECT
 	*
FROM INFORMATION_SCHEMA.COLUMNS 
-- For the customer table
WHERE table_name = 'customer';


-- Accessing data in an ARRAY: Select the title and special features column 
SELECT 
  title, 
  special_features 
FROM film
WHERE special_features[2] = 'Deleted Scenes';

-- Searching an ARRAY with ANY
SELECT
  title, 
  special_features 
FROM film 
WHERE 'Trailers' = ANY (special_features);

-- Searching an ARRAY with @>
SELECT 
  title, 
  special_features 
FROM film 
WHERE special_features @> ARRAY['Deleted Scenes'];


-- Adding and subtracting date and time values
SELECT f.title, f.rental_duration,
	AGE(r.return_date, r.rental_date) AS days_rented
FROM film AS f
	INNER JOIN inventory AS i ON f.film_id = i.film_id
	INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;

--Calculating the expected return date
SELECT
    f.title,
	  r.rental_date,
    f.rental_duration,
    INTERVAL '1' day * f.rental_duration + rental_date AS expected_return_date,
    r.return_date
FROM film AS f
    INNER JOIN inventory AS i ON f.film_id = i.film_id
    INNER JOIN rental AS r ON i.inventory_id = r.inventory_id
ORDER BY f.title;

-- Manipulating the current date and time
SELECT
	CURRENT_TIMESTAMP(2)::timestamp AS right_now,
    interval '5 days' + CURRENT_TIMESTAMP(2) AS five_days_from_now;


-- Using EXTRACT Extract day of week from rental_date
SELECT 
  EXTRACT(dow FROM rental_date) AS dayofweek, 
  COUNT(rental_date) as rentals 
FROM rental 
GROUP BY 1;


-- Using DATE_TRUNC
SELECT 
  DATE_TRUNC('day', rental_date) AS rental_day,
  COUNT(rental_date) AS rentals 
FROM rental
GROUP BY 1;

--Use some date/time functions to extract and manipulate some DVD rentals data from our fictional DVD rental store.
SELECT 
  c.first_name || ' ' || c.last_name AS customer_name,
  f.title,
  r.rental_date,
  EXTRACT(dow FROM r.rental_date) AS dayofweek,
  AGE(r.return_date, r.rental_date) AS rental_days,
  CASE WHEN DATE_TRUNC('day', AGE(r.return_date, r.rental_date)) > 
    f.rental_duration * INTERVAL '1' day 
  THEN TRUE 
  ELSE FALSE END AS past_due 
FROM 
  film AS f 
  INNER JOIN inventory AS i 
  	ON f.film_id = i.film_id 
  INNER JOIN rental AS r 
  	ON i.inventory_id = r.inventory_id 
  INNER JOIN customer AS c 
  	ON c.customer_id = r.customer_id 
WHERE 
  r.rental_date BETWEEN CAST('2005-05-01' AS DATE) 
  AND CAST('2005-05-01' AS DATE) + INTERVAL '90 day';

-- Concatenating strings: Concatenate the first_name and last_name and email
SELECT CONCAT(first_name, ' ', last_name, ' <' , email, '>' ) AS full_email 
FROM customer


-- Replacing string data
SELECT 
  -- Replace whitespace in the film title with an underscore
  REPLACE(title, ' ', '_') AS title
FROM film; 


-- Determining the length of strings
SELECT 
  title,
  description,
  length(description) AS desc_len
FROM film;

-- Truncating strings
SELECT 
  LEFT(description, 50) AS short_desc
FROM 
  film AS f; 

-- Combined Exercise: How many of our customers use an email from a specific domain.
SELECT
  SUBSTRING(email FROM 0 FOR POSITION('@' IN email)) AS username,
  SUBSTRING(email FROM POSITION('@' IN email)+1 FOR LENGTH(email)) AS domain
FROM customer;

-- Padding and TRIM
SELECT 
  UPPER(c.name) || ': ' || f.title AS film_category, 
  -- Truncate the description without cutting off a word
  LEFT(description, 50 - 
    -- Subtract the position of the first whitespace character
    POSITION(
      ' ' IN REVERSE(LEFT(description, 50))
    )
  ) 
FROM 
  film AS f 
  INNER JOIN film_category AS fc 
  	ON f.film_id = fc.film_id 
  INNER JOIN category AS c 
  	ON fc.category_id = c.category_id;

--Basic full-text search: Perform a full-text search on the title column for the word elf.
SELECT title, description
FROM film
WHERE to_tsvector(title) @@ to_tsquery('elf');

-- Create a tsvector from the description column in the film table. 
-- You will match against a tsquery to determine if the phrase "Astounding Drama" leads to more rentals per month.
-- Next, create a new column using the similarity function to rank the film descriptions based on this phrase.

SELECT 
  title, 
  description, 
  -- Calculate the similarity
  similarity(description, 'Astounding Drama')
FROM 
  film 
WHERE 
  to_tsvector(description) @@ 
  to_tsquery('Astounding & Drama') 
ORDER BY 
	similarity(description, 'Astounding Drama') DESC;