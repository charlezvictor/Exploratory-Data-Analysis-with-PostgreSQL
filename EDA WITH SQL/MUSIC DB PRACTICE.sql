-- EXPLORATORY DATA ANALYSIS WITH SQL ON MUSIC DATABASE

--Q1 Who is the senior most employess based on job title
Select * from employee
where reports_to is null
order by levels desc

-- Q2 Which countries have the most invoices?
Select * from invoice

Select billing_country, count(invoice_id) as invoices
from invoice
group by billing_country 
order by invoices desc

-- Q3 What are top 3 values of total invoices
Select * from invoice
order by total desc
limit 3

-- Q4 Which city has the best customers? We would like to throw a promotional
-- music festival in the city we made the most money. Write a query taht returns one 
-- city that has the highest sum of invoice totals.
-- Returns both the city name and sum of all invoice totals

select billing_city, sum(total) as Totals
from invoice
group by billing_city
order by Totals desc
limit 1

-- Q5 Who is the best customer? Customer that has spent the most money
select * from customer

Select c.customer_id, c.first_name, c.last_name, billing_country, sum(total) as Money_spent
from customer c inner join invoice i
on c.customer_id = i.customer_id
group by c.customer_id,billing_country, c.first_name, c.last_name
order by 5 desc
limit 1

-- Q6 Query to return email, firstname, lastname and Genre of all Rock Music listeners
--- Return your list ordered alphabetically by email starting with A

Select * from genre
select * from track
select * from album
select * from artist

with rock_music as(
select * from track
where genre_id = '1'
)
select * from rock_music

select * from invoice_line

-- Real Code Answer
Select DISTINCT first_name, last_name, email, g.name
from customer c join invoice i
on c.customer_id = i.customer_id
join invoice_line v
on i.invoice_id = v.invoice_id
join track t
on v.track_id = t.track_id
join genre g
on t.genre_id = g.genre_id
Where g.genre_id = '1'
order by email asc

-- Q7 Artist who has written the most rock music, query that returns Artsist name and total
-- track count of the top 10 rock bands

select count(track_id) number_of_tracks,a.name, g.name
from album join artist a 
on album.artist_id = a.artist_id
join track t
on album.album_id = t.album_id
join genre g
on t.genre_id = g.genre_id
where g.genre_id = '1'
group by a.name, t.genre_id, g.name
order by number_of_tracks desc
limit 10

-- Q8 Return all the track names that have song length longer than the average song length
-- Return the name and milliseconds for each track. order by song length with longest songs listed first
select name, avg(milliseconds) as average_song_length  from track
group by name
order by average_song_length desc

-- OR

select name, milliseconds
from track
where milliseconds >(
	select avg(milliseconds) as avg_track_length
	from track)
order by milliseconds desc


-- Q9 Money spent by each customer on artist, 
-- query that returns customer name, artist name and total spent

Select first_name, last_name, a.name as Artist_name, SUM(Total) as Total_spent, count(t.track_id)
from customer c join invoice i
on c.customer_id = i.customer_id
join invoice_line v
on i.invoice_id = v.invoice_id
join track t
on v.track_id = t.track_id
join album ab
on t.album_id = ab.album_id
join artist a
on ab.artist_id = a.artist_id
group by 1,2,3
order by 4 desc


-- Q10 Find how much each customer spent on the most Best Selling Artist.
with best_selling_artist as (
Select a.name, a.artist_id, sum(inl.unit_price * inl.quantity) as revenue_per_artist, count(t.track_id)
from invoice_line inl join track t
on inl.track_id = t.track_id
join album ab
on t.album_id = ab.album_id
join artist a
on ab.artist_id = a.artist_id
group by 1,2
order by 3 desc
limit 1
)

Select c.first_name, c.last_name, bsa.name as Artist_name, sum(v.unit_price * v.quantity) as Total_spent, count(t.track_id)
from customer c join invoice i
on c.customer_id = i.customer_id
join invoice_line v
on i.invoice_id = v.invoice_id
join track t
on v.track_id = t.track_id
join album ab
on t.album_id = ab.album_id
join best_selling_artist bsa
on ab.artist_id = bsa.artist_id
group by 1,2,3
order by 4 desc


-- Q11 Most Popular Genre for each country.
-- Genre with the highest amount of purchases
-- Write a query that return each country along with the top genre, for countires where the maximum number of 
--- purchases is shared, return all genres

-- Using CTEs
WITH popular_genre AS 
(
    SELECT g.genre_id, g.name, c.country, COUNT(inl.quantity) AS purchases, 
		ROW_NUMBER() OVER(PARTITION BY c.country ORDER BY COUNT(inl.quantity) DESC) AS RowNo 
    FROM invoice_line inl JOIN invoice i 
	ON inl.invoice_id = i.invoice_id
	JOIN customer c 
	ON i.customer_id = c.customer_id
	JOIN track t 
	ON inl.track_id = t.track_id
	JOIN genre g 
	ON t.genre_id = g.genre_id
	GROUP BY 1,2,3
	ORDER BY 3 ASC, 4 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1

-- Q12 Write a query that determines the customer that has spent the most on music for each country. 
-- Write a query that returns the country along with the top customer and how much they spent. 
-- For countries where the top amount spent is shared, provide all customers who spent this amount

WITH customer_spending AS (
    SELECT c.customer_id, c.country,c.first_name, c.last_name, SUM(invoice.total) AS total_spending,
           RANK() OVER (PARTITION BY c.country ORDER BY SUM(invoice.total) DESC) AS rank
    FROM customer c
    JOIN invoice ON c.customer_id = invoice.customer_id
    GROUP BY c.customer_id, c.country
)
SELECT first_name, last_name, country, customer_id, total_spending
FROM customer_spending
WHERE rank = 1



