USE sakila;

-- 1a Display the first and last names of all actors from the table actor.
SET SQL_SAFE_UPDATES = 0;
Select first_name, last_name
From actor;

-- 1b Display the first and last name of each actor in a single column in upper case letters. 
-- Name the column Actor Name.
select UPPER(CONCAT(first_name, ', ', last_name)) as 'Actor Name'
from actor;

-- 2a You need to find the ID number, first name, and last name of an actor, 
-- of whom you know only the first name, "Joe." What is one query would you use to obtain this information?
Select actor_id, first_name, last_name
from actor
where first_name like 'Joe%';

-- 2b Find all actors whose last name contain the letters GEN:
Select actor_id, first_name, last_name
from actor
where last_name like '%Gen%';

-- 2c Find all actors whose last names contain the letters LI. This time, order the rows 
-- by last name and first name, in that order:
Select actor_id, first_name, last_name
from actor
where last_name like '%Li%'
order by last_name, first_name;

-- 2d Using IN, display the country_id and country columns of the following 
-- countries: Afghanistan, Bangladesh, and China:
Select country_id, country
from country
where country IN ('Afghanistan', 'Bangladesh', 'China');

-- 3a You want to keep a description of each actor. You don't think you will be performing queries on 
-- a description, so create a column in the table actor named description and use the data type BLOB 
-- (Make sure to research the type BLOB, as the difference between it and VARCHAR are significant).
ALTER TABLE actor
ADD COLUMN description BLOB AFTER last_name;

-- confirming table altererd
Select * from actor;

-- 3b Very quickly you realize that entering descriptions for each actor is too much effort. 
-- Delete the description column.
ALTER TABLE actor 
DROP COLUMN description;

-- Use this to verify column was dropped
Select * from actor;

-- 4a List the last names of actors, as well as how many actors have that last name.
SELECT last_name, COUNT(*) as 'number of actors with same last name'
FROM actor
GROUP BY last_name
ORDER BY COUNT(*) DESC;

--  4b List last names of actors and the number of actors who have that last name, but only for names that are 
-- shared by at least two actors

SELECT last_name, COUNT(*) as 'number of actors with same last name'
FROM actor
GROUP BY last_name
Having count(*) >= 2
ORDER BY COUNT(*) DESC;

-- 4c The actor HARPO WILLIAMS was accidentally entered in the actor table as GROUCHO WILLIAMS. 
-- Write a query to fix the record.
SET SQL_SAFE_UPDATES = 0;
UPDATE actor 
SET 
    first_name = 'HARPO'
WHERE
    actor_id = 172;
    
-- 4d   Perhaps we were too hasty in changing GROUCHO to HARPO. It turns out that GROUCHO was 
-- the correct name after all! In a single query, if the first name of the actor is currently 
-- HARPO, change it to GROUCHO. 
    UPDATE actor
 SET first_name = replace(first_name, 'HARPO', 'GROUCHO');
 
-- 5a. You cannot locate the schema of the address table. Which query would you use to re-create it?
describe sakila.address;
 
 -- 6a Use JOIN to display the first and last names, as well as the address, of each staff member. 
 -- Use the tables staff and address:
 Select s.staff_id,s.first_name, s.last_name, a.address, a.address2, a.district, a.city_id, a.postal_code
 From address as a inner join
 staff as s on a.address_id = s.address_id;
 
 -- 6b Use JOIN to display the total amount rung up by each staff member in August of 2005. 
 -- Use tables staff and payment.
 Select s.staff_id,s.first_name, s.last_name, concat('$', format(sum(p.amount),2)) as total_amount, p.payment_date
 From staff as s inner join
 payment as p on s.staff_id = p.staff_id
 WHERE YEAR(p.payment_date) = 2005 AND MONTH(p.payment_date) = 8
 group by staff_id;
 
 -- 6c  List each film and the number of actors who are listed for that film. Use tables film_actor and film. Use inner join.
 Select fa.actor_id, f.title,f.description, count(*) as 'number of actors listed for the film'
 from film_actor as fa inner join
		film as f on fa.film_id = f.film_id
group by fa.actor_id;

--  6d  How many copies of the film Hunchback Impossible exist in the inventory system?
Select f.film_id, f.title, f.description, count(*) as 'no in inventory'
From inventory as i inner join
film as f on f.film_id = i.film_id
where f.title Like 'Hunch%';

-- 6e Using the tables payment and customer and the JOIN command, list the total paid by each customer. 
-- List the customers alphabetically by last name:
Select c.customer_id,c.first_name, c.last_name, concat('$', format(sum(p.amount),2)) As total_amount_paid
from customer as c inner join
	 payment p on c.customer_id = p.customer_id
Group by c.customer_id
order by c.last_name ASC;

-- 7a The music of Queen and Kris Kristofferson have seen an unlikely resurgence. 
-- As an unintended consequence, films starting with the letters K and Q have also soared in popularity. 
-- Use subqueries to display the titles of movies starting with the letters K and Q whose language is English.

SELECT title as 'Title of movies starting with letter K or Q'
FROM film
WHERE (title LIKE 'K%'
 or title LIKE 'Q%' )
	AND language_id=
			(SELECT language_id 
            FROM language 
            where name='English');
            
-- 7b Use subqueries to display all actors who appear in the film Alone Trip
Select first_name, last_name
from actor 
where actor_id IN
				(select actor_id
				from film_actor
                where film_id IN
								(select film_id
                                from film
                                where title = 'Alone Trip'));
                                
-- 7c You want to run an email marketing campaign in Canada, for which you will need 
-- the names and email addresses of all Canadian customers. Use joins to retrieve this information.

Select c.first_name, c.last_name, c.email, k.country
from customer c inner join
	address a on c.address_id = a.address_id inner join
    city t on t.city_id = a.city_id inner join
    country k on t.country_id = k.country_id
where country like 'CANA%';

-- 7d Sales have been lagging among young families, and you wish to target all family movies for a promotion. 
-- Identify all movies categorized as family films.
select c.name, f.title, f.description
from category c Join
	film_category fc on c.category_id = fc.category_id join
    film_text f on f.film_id = fc.film_id
where c.name Like 'fami%'; 

-- 7e Display the most frequently rented movies in descending order.
SELECT f.title, COUNT(*) as 'most frequently rented movies'
FROM payment p JOIN 
	 rental r ON p.rental_id = r.rental_id JOIN 
     inventory i ON r.inventory_id = i.inventory_id JOIN 
     film f ON i.film_id = f.film_id
	GROUP BY f.title
	ORDER BY COUNT(*) DESC;
    
-- 7f Write a query to display how much business, in dollars, each store brought in.
SELECT s.store_id, concat('$',format(SUM(p.amount),2)) AS USD 
FROM staff s JOIN 
	 payment p ON s.staff_id = p.staff_id
	GROUP BY s.store_id;
    
-- 7g Write a query to display for each store its store ID, city, and country.
	SELECT s.store_id, c.city, k.country 
    FROM staff s JOIN 
    address a ON s.address_id = a.address_id JOIN 
    city c ON a.city_id = c.city_id JOIN 
    country k ON c.country_id = k.country_id;
    
-- 7h List the top five genres in gross revenue in descending order. 
-- (Hint: you may need to use the following tables: category, 
-- film_category, inventory, payment, and rental.)

SELECT c.name AS Genre, concat('$',format(SUM(p.amount),2)) AS Gross_Revenue 
FROM category c JOIN 
film_category fc ON c.category_id = fc.category_id JOIN 
inventory i ON fc.film_id = i.film_id JOIN 
rental r ON i.inventory_id = r.inventory_id JOIN 
payment p ON r.rental_id = p.rental_id
	GROUP BY Genre
	ORDER BY SUM(p.amount) DESC
    LIMIT 5;
    
-- 8a. In your new role as an executive, you would like to have an easy way of viewing the 
-- Top five genres by gross revenue. Use the solution from the problem above to 
-- create a view. If you haven't solved 7h, you can substitute another query to create a view
CREATE VIEW Top_Five_revenue as 
SELECT c.name AS Genre, concat('$',format(SUM(p.amount),2)) AS Gross_Revenue 
FROM category c JOIN 
film_category fc ON c.category_id = fc.category_id JOIN 
inventory i ON fc.film_id = i.film_id JOIN 
rental r ON i.inventory_id = r.inventory_id JOIN 
payment p ON r.rental_id = p.rental_id
	GROUP BY Genre
	ORDER BY SUM(p.amount) DESC
    LIMIT 5;

-- 8b. How would you display the view that you created in 8a?

Select * 
From Top_Five_revenue;


-- 8c. You find that you no longer need the view top_five_genres. Write a query to delete it.
DROP VIEW Top_Five_revenue;
