CREATE DATABASE mainprojects;
SELECT * FROM album;

-- EASY
-- 1. Senior most employee based on job title ?
SELECT * FROM employee
ORDER BY levels DESC
LIMIT 1;

-- 2. Which countries have the most invoices ?
SELECT billing_country, COUNT(*) AS num_invoice FROM invoice
GROUP BY billing_country
ORDER BY num_invoice DESC;

-- 3. Whta are top 3 values of total invoices ?
SELECT invoice_id, total FROM invoice
ORDER BY total DESC
LIMIT 3;

-- 4. Which city has the best customers in terms of total invoice ?
SELECT billing_city, SUM(total) AS total_invoice FROM invoice
GROUP BY billing_city
ORDER BY total_invoice DESC
LIMIT 1;

-- 5. Who is the best customer ? Customer whos has spent the most amount of money
SELECT t1.customer_id, ANY_VALUE(first_name), ANY_VALUE(last_name), ANY_VALUE(country), SUM(total) AS invoice_total FROM customer t1
JOIN invoice t2 
ON t1.customer_id = t2.customer_id
GROUP BY customer_id
ORDER BY invoice_total DESC
LIMIT 1;

-- MODERATE
-- 1. Write a query to return email, first name, last name, genre of all rock music listeners, Sort by email
SELECT DISTINCT first_name, last_name, email FROM customer t1
JOIN invoice t2 ON t1.customer_id=t2.customer_id
JOIN invoice_line t3 ON t2.invoice_id=t3.invoice_id
WHERE track_id IN (SELECT track_id FROM track t4 
				   JOIN genre t5 ON  t4.genre_id=t5.genre_id 
                    WHERE t5.name LIKE 'ROCK')
ORDER BY email;

-- 2. Let's invite the artist who has written the most rock music in our dataset. Write a query that returns the artist name and total
-- track count of top 10 rock bands -> artist, album, track, genre
SELECT ANY_VALUE(t1.name), COUNT(*) AS rock_music_num FROM artist t1
JOIN album t2 ON t1.artist_id = t2.artist_id
JOIN track t3 ON t2.album_id = t3.album_id
JOIN genre t4 ON t3.genre_id = t4.genre_id
WHERE t4.name LIKE 'rock'
GROUP BY t2.artist_id
ORDER BY rock_music_num DESC
LIMIT 10;

-- 3. Return all the track names that have a song length longer than the avg song length. Return the name, milliseconds for each track.
-- Order by song length in descending order. 393599.2121

SELECT name, milliseconds FROM track WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC;

-- HARD
-- 1. Find how much amount spent by each customer on artists? Return customer name, artist name, total spend
''' SELECT CONCAT(ANY_VALUE(t1.first_name),' ', ANY_VALUE(t1.last_name)) AS cust_name, ANY_VALUE(t6.name) AS artist_name, SUM(total) AS total_spent FROM customer t1 
JOIN invoice t2 ON t1.customer_id=t2.customer_id
JOIN invoice_line t3 ON t2.invoice_id = t3.invoice_id
JOIN track t4 ON t3.track_id=t4.track_id
JOIN album t5 ON t4.album_id=t5.album_id
JOIN artist t6 ON t5.artist_id=t6.artist_id
GROUP BY t1.customer_id, t6.artist_id
ORDER BY cust_name; '''

WITH best_selling_artist AS (
SELECT ar.artist_id as artist_id, ANY_VALUE(ar.name) as artist_name, SUM(ANY_VALUE(i.unit_price)*ANY_VALUE(i.quantity)) AS total_sales FROM 
invoice_line i
JOIN track t ON i.track_id=t.track_id
JOIN album al ON t.album_id=al.album_id
JOIN artist ar ON al.artist_id=ar.artist_id
GROUP BY ar.artist_id
ORDER BY total_sales DESC
LIMIT 1) 

SELECT CONCAT(ANY_VALUE(C.first_name),' ', ANY_VALUE(C.last_name)) AS cust_name, ANY_VALUE(bsa.artist_name), 
SUM(ANY_VALUE(il.unit_price)*ANY_VALUE(il.quantity)) AS total_spent FROM customer c
JOIN invoice i ON c.customer_id=i.customer_id
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN track t ON il.track_id=t.track_id
JOIN album al ON t.album_id=al.album_id
JOIN best_selling_artist bsa ON al.artist_id=bsa.artist_id
GROUP BY c.customer_id
ORDER BY total_spent DESC;

-- 2 Find out the most popular music genre for each country. Determine this by the genre with the highest no. of purchases.
-- Return each country with the top genre name. For the countries where the max no. of purchases is same return all the genres.
WITH CTE AS(
SELECT i.billing_country AS country, g.name as genre_name, COUNT(il.quantity) as purchases FROM invoice i
JOIN invoice_line il ON i.invoice_id=il.invoice_id
JOIN track t ON il.track_id=t.track_id
JOIN genre g ON t.genre_id=g.genre_id
GROUP BY i.billing_country, g.name
ORDER BY i.billing_country, purchases DESC)

SELECT t.country,t.genre_name FROM (
SELECT *,dense_rank() OVER(PARTITION BY country ORDER BY purchases DESC) AS ranking FROM CTE) t
WHERE t.ranking =1;

-- 3 Find out the customer who has spent the most on music for each country. Write a query to return the country along with the top most customer and 
-- the amount spent. For the countries where the top amount is shared return all the customers with that amount.
WITH CTE AS(
SELECT c.customer_id, CONCAT(ANY_VALUE(c.first_name),' ' ,ANY_VALUE(c.last_name)) AS name, ANY_VALUE(i.billing_country) as country, SUM(ANY_VALUE(i.total)) AS total_spent
FROM customer c 
JOIN invoice i ON c.customer_id=i.customer_id
-- JOIN invoice_line il ON i.invoice_id=il.invoice_id
GROUP BY c.customer_id
ORDER BY name )

SELECT customer_id, name, country, total_spent FROM(
SELECT *, ROW_NUMBER() OVER(PARTITION BY country ORDER BY total_spent DESC) AS ranking FROM CTE
ORDER BY country ) t
WHERE ranking = 1;








                    






