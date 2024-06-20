
/*
SQL Case study project
*/

create database pizza_project;

use pizza_project

-- Now understand each table (all columns)
select * from order_details;  -- order_details_id	order_id	pizza_id	quantity

select * from pizzas -- pizza_id, pizza_type_id, size, price

select * from orders  -- order_id, date, time

select * from pizza_types;  -- pizza_type_id, name, category, ingredients

-- Retrieve the total number of orders placed.
select count(distinct order_id) as "Total Orders" from orders;

-- Calculate the total revenue generated from pizza sales.

-- to see the details
select order_details.pizza_id, order_details.quantity, pizzas.price
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id

-- to get the answer
select cast(sum(order_details.quantity * pizzas.price) as decimal(10,2)) as "Total Revenue"
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id


-- Identify the highest-priced pizza.

with cte as (
select pizza_types.name as "Pizza_Name", cast(pizzas.price as decimal(10,2)) as "Price",
rank() over (order by price desc) as rnk
from pizzas
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
)
select "Pizza_Name","Price" from cte where rnk = 1 



-- Identify the most common pizza size ordered.

select pizzas.size, count(distinct order_id) as "No of Orders", sum(quantity) as "Total Quantity Ordered"
from order_det
join pizzas on pizzas.pizza_id = order_details.pizza_id
-- join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizzas.size
order by count(distinct order_id) desc
limit 1


-- List the top 5 most ordered pizza types along with their quantities.

select pizza_types.name as "Pizza", sum(quantity) as "Total Ordered"
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name 
order by sum(quantity) desc
limit 5


-- Join the necessary tables to find the total quantity of each pizza category ordered.

select pizza_types.category, sum(quantity) as "Total Quantity Ordered"
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category 
order by sum(quantity)  desc


-- Determine the distribution of orders by hour of the day.

select extract(hour from time) as "Hour of the day", count(distinct order_id) as "No of Orders"
from orders
group by extract(hour from time) 
order by 2 desc



-- find the category-wise distribution of pizzas

select category, count(distinct pizza_type_id) as "No of pizzas"
from pizza_types
group by category
order by 2

-- Calculate the average number of pizzas ordered per day.

with cte as(
select orders.date as "Date", sum(order_det.quantity) as "Total Pizza Ordered that day"
from order_details
join orders on order_details.order_id = orders.order_id
group by orders.date
)
select avg("Total Pizza Ordered that day") as "Avg Number of pizzas ordered per day"  from cte

-- Determine the top 3 most ordered pizza types based on revenue.

select  pizza_types.name, sum(order_details.quantity*pizzas.price) as "Revenue from pizza"
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by 2 desc limit 3

-- Calculate the percentage contribution of each pizza type to total revenues

select pizza_types.category, 
concat(cast((sum(order_details.quantity*pizzas.price) /--find revenue for each pizza category  
(select sum(order_details.quantity*pizzas.price) --this subquery finds the total revenue
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id 
))*100 as decimal(10,2)), '%')
as "Revenue contribution from pizza"
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.category
order by 2 desc

-- revenue contribution from each pizza by pizza name
  
select pizza_types.name, 
concat(cast((sum(order_det.quantity*pizzas.price) /
(select sum(order_det.quantity*pizzas.price) 
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id 
))*100 as decimal(10,2)), '%')
as "Revenue contribution from pizza"
from order_details 
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by pizza_types.name
order by 2 desc


-- Analyze the cumulative revenue generated over time.
-- use of aggregate window function (to get the cumulative sum)
  
with cte as (
select date as "Date", cast(sum(quantity*price) as decimal(10,2)) as "Revenue"
from order_details
join orders on order_details.order_id = orders.order_id
join pizzas on pizzas.pizza_id = order_details.pizza_id
group by date
)
select "Date", "Revenue", sum("Revenue") over (order by "Date") as "Cumulative Sum"
from cte 
group by 1,2


-- Determine the top 3 most ordered pizza types based on revenue for each pizza category.

with cte as (
select category, name, cast(sum(quantity*price) as decimal(10,2)) as Revenue
from order_details
join pizzas on pizzas.pizza_id = order_details.pizza_id
join pizza_types on pizza_types.pizza_type_id = pizzas.pizza_type_id
group by category, name
)
, cte1 as (
select category, name, Revenue,
rank() over (partition by category order by Revenue desc) as rnk
from cte 
)
select category, name, Revenue
from cte1 
where rnk in (1,2,3)
order by category, name, Revenue
