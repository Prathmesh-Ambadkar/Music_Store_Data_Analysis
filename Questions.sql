Create database musicDB;
use musicDB;

/* Q1: Who is the senior most employee based on job title? */
select * from employee
order by levels desc;

/* Q2: Which countries have the most Invoices? */

select * from invoice;
select billing_country, count(invoice_id) as totalinvoice
from invoice
group by billing_country
order by totalinvoice desc
limit 1;

/* Q3: What are top 3 values of total invoice? */
select * from invoice
order by total desc
limit 3;

/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

select  billing_city, sum(total) as totalpercity
from invoice 
group by billing_city
order by totalpercity desc
limit 1;

/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

select c.customer_id,c.first_name, c.last_name,sum(i.total) as totalsepndbycustomer
from customer c
join invoice i
on c.customer_id = i.customer_id
group by c.customer_id
order by totalsepndbycustomer desc
limit 1;

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

/*Method 1 */

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;


/* Method 2 */

SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoiceline ON invoiceline.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoiceline.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;

/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

select a.artist_id, a.name , COUNT(a.artist_id) as number_of_songs
from track t
join album2 al
on al.album_id = t.track_id
join Artist a
ON a.artist_id = al.artist_id
join genre g
on g.genre_id = t.genre_id
where g.name LIKE 'Rock'
GROUP BY a.artist_id
order by number_of_songs desc
LIMIT 10;

/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */

SELECT name, milliseconds
FROM track
WHERE milliseconds > (
	SELECT AVG(milliseconds) AS avg_song_length
	FROM track )
ORDER BY milliseconds DESC;

/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on artists? Write a query to return customer name, artist name and total spent */

/* Steps to Solve: First, find which artist has earned the most according to the InvoiceLines. Now use this artist to find 
which customer spent the most on this artist. For this query, you will need to use the Invoice, InvoiceLine, Track, Customer, 
Album, and Artist tables. Note, this one is tricky because the Total spent in the Invoice table might not be on a single product, 
so you need to use the InvoiceLine table to find out how many of each product was purchased, and then multiply this by the price
for each artist. */

WITH cte as
(select a.artist_id, a.name as artist_name, SUM(il.unit_price * il.quantity) as totalAmount
from invoice_line il
Join track t
on il.track_id= t.track_id
Join album2 al
On al.album_id = t.album_id
join artist a
On a.artist_id = al.artist_id
group by 1
order by 3 desc
LIMIT 1
)
select c.customer_id, c.first_name, c.last_name, bse.artist_name, SUM(il.unit_price*il.quantity) AS amount_spent
from invoice i
join customer c
on i.customer_id = c.customer_id
join invoice_line  il
on il.invoice_id = i.invoice_id
join track t
on t.track_id = il.track_id
join album2 al 
on al.album_id = t.album_id
Join cte bse on bse.artist_id = al.artist_id
group by 1,2,3,4
order by 5 desc;


/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

/* Steps to Solve:  There are two parts in question- first most popular music genre and second need data at country level. */

/* Method 1: Using CTE */

WITH popular_genre as
(Select COUNT(il.quantity) AS purchases, c.country, g.name, g.genre_id,
ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(il.quantity) DESC) AS RowNo 
from invoice_line il
JOIN invoice i
On il.invoice_id = i.invoice_id
Join track t 
on t.track_id = il.track_id
join genre g
on g.genre_id = t.genre_id
join customer c
on c.customer_id = i.customer_id
group by 2,3,4
order by 2 ASC, 1 DESC)
SELECT * FROM popular_genre WHERE RowNo <= 1;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

/* Steps to Solve:  Similar to the above question. There are two parts in question- 
first find the most spent on music for each country and second filter the data for respective customers. */

/* Method 1: using CTE */

WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1
