
---- Assignment on  Windows Function -----

---- 1. Rank the customers based on the total amount they have spent on rentals --- 

 select customer.customer_id, 
 customer.first_name,
 customer.last_name ,
 sum(payment.amount) Total_amount, 
 rank() over(order by  sum(payment.amount) desc) as Ranking
 from customer join rental on customer.customer_id = rental.customer_id 
 join payment on rental.rental_id=payment.rental_id 
 group by customer.customer_id 
 order by total_amount desc;
 
---- 2.Calculate the cumulative revenue generated by each film over time.---

 select film.film_id,film.title, payment.payment_date,sum(payment.amount) 
 over(partition by film.film_id order by payment.payment_date) as cumulative_revenue
 from film join inventory on film.film_id = inventory.film_id
 join rental on inventory.inventory_id=rental.inventory_id 
 join payment  on rental.rental_id = payment.rental_id
 order by film.film_id , payment.payment_date;
 
 ---- 3.Determine the average rental duration for each film, considering films with similar lengths.---

select film_id,title,length, avg(rental_duration) 
over(partition by length) as Avg_Rental_Duration_similar_lengths 
from film;

---- 4.Identify the top 3 films in each category based on their rental counts.---

with rankedfilm as ( 
 select film.film_id, film.title, category.name as Category, count(rental.rental_id) as Rental_count,
 row_number() over(partition by category.name order by count(rental.rental_id)desc) As 'Ranking' from film
 join film_category on film.film_id = film_category.film_id 
 join category on film_category.category_id = category.category_id 
 join inventory on film.film_id = inventory.film_id
 join rental on inventory.inventory_id=rental.inventory_id
group by film.film_id, film.title, category.name)

select film_id,title,category,Rental_count
 from rankedfilm where ranking <=3;


---- 5.Calculate the difference in rental counts between each customers total rentals and the average rentals across all customers.---

with CustomerRental as (
 select customer.customer_id , customer.first_name , customer.last_name,
 count(rental.rental_id) as total_rental,
 avg(count(rental.rental_id)) 
 over() as avg_rental from customer 
 join rental on customer.customer_id = rental.customer_id
 group by customer.customer_id)

 select customer_id, first_name, last_name, total_rental-avg_rental as rental_difference  from CustomerRental;

---- 6.Find the monthly revenue trend for the entire rental store over time.---

 select date_format(payment.payment_date,'%Y-%m') 
 AS Month ,sum(payment.amount)
 over(order by date_format(payment.payment_date,'%Y-%m'))as monthly_revenue from store 
 join rental on store.manager_staff_id = rental.staff_id 
 join payment on rental.rental_id = payment.rental_id;
 
 ---- 7.Identify the customers whose total spending on rentals falls within the top 20% of all customers.---
 
 with customer_total_spending as(
 select customer.customer_id , customer.first_name, customer.last_name ,
 sum(payment.amount) total_spending, percent_rank() 
 over(order by sum(payment.amount) desc) as spending_percentage from customer
 join rental on customer.customer_id = rental.customer_id  
 join payment on rental.rental_id = payment.rental_id 
 group by customer.customer_id, customer.first_name, customer.last_name )

 select customer_id, first_name ,last_name,total_spending 
 from customer_total_spending where spending_percentage<=0.2
 order by total_spending desc;

 
 
 ---- 8.Calculate the running total of rentals per category, ordered by rental count.--- 
 
 select category.name as Category, count(rental.rental_id) as Rental_count, sum(count(rental.rental_id))
 over(order by count(rental.rental_id )desc) as Running_total 
 from category  join film_category on category.category_id = film_category.category_id 
 join film on film_category.film_id = film.film_id 
 join inventory on  film.film_id = inventory.film_id 
 join rental on inventory.inventory_id = rental.inventory_id group by category.name;
 
 ---- 9.Find the films that have been rented less than the average rental count for their respective categories.

with avg_rental_per_category as
 (select film.film_id ,film.title , category.name as category  , count(rental.rental_id) as rental_count, avg(count(rental.rental_id)) 
over(partition by category.name ) as avg_rental_count 
from category join film_category on category.category_id = film_category.category_id 
join film on film_category.film_id = film.film_id 
join inventory on film.film_id = inventory.film_id
join rental on inventory.inventory_id =
rental.inventory_id group by film.film_id , film.title, category.name order by category.name)

select film_id, title, category, rental_count AS rental_count, avg_rental_count AS average_rental_count
from  avg_rental_per_category 
where rental_count < avg_rental_count
group by film_id, title, category order by category,film_id;

--- 10.Identify the top 5 months with the highest revenue and display the revenue generated in each month.

with monthly_revenue as (
select date_format(payment_date,'%Y-%m') as Month, sum(payment.amount) as Revenue, row_number() over(order by sum(payment.amount)desc)
as row_no from payment group by month )

select Month , Revenue from monthly_revenue  where row_no <=5;























