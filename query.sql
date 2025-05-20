create database Pizza_Sales;

use pizza_sales;

/*Create Orders table*/
create table orders(
Order_ID int not null,
Order_Date date not null,
Order_Time time not null,
primary key(Order_ID));

/*Create Order Details table*/
create table Order_Details(
Order_Details_ID int not null,
Order_ID int not null,
Pizza_ID text not null,
quantity int not null,
primary key(Order_Details_ID));

/*1. Retrieve the total number of orders placed.*/

Select count(order_id) as Total_Order from Orders;

-- 2. Calculate the total revenue generated from pizza sales.

SELECT 
    ROUND(SUM(Order_details.quantity * Pizzas.Price),
            2) AS Total_Sales
FROM
    order_details
        JOIN
    pizzas ON pizzas.pizza_id = order_details.pizza_id
 
-- 3. Identify the highest-priced pizza.

select Pizza_types.name, Pizzas.Price
FROM
    pizza_types
        JOIN
    pizzas ON Pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY Pizzas.price DESC
LIMIT 1;

-- 4. Identify the most common pizza size ordered.

Select quantity, count(order_details_id)
from order_details group by quantity;

SELECT 
    pizzas.size,
    COUNT(order_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    order_details ON pizzas.pizza_id = order_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC;

-- 5. List the top 5 most ordered pizza types along with their quantities.

SELECT 
    pizza_types.name, SUM(order_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = Pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.Pizza_id
GROUP BY pizza_types.name
ORDER BY Quantity DESC
LIMIT 5;

-- 6. Join the necessary tables to find the total quantity of each pizza category ordered.

SELECT 
    pizza_types.category,
    SUM(order_details.quantity) AS Quantity
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = Pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY quantity DESC;


-- 7. Determine the distribution of orders by hour of the day.

SELECT 
    HOUR(order_time) AS Hour, COUNT(order_id) AS Count
FROM
    orders
GROUP BY HOUR(order_time);

-- 8. Join relevant tables to find the category-wise distribution of pizzas.
select category, count(name) from pizza_types
group by category;

-- 9. Group the orders by date and calculate the average number of pizzas ordered per day.

SELECT 
    ROUND(AVG(quantity), 0) as Avg_Pizza_order_per_day
FROM
    (SELECT 
        orders.order_date, SUM(order_details.quantity) AS quantity
    FROM
        orders
    JOIN order_details ON orders.order_id = order_details.order_id
    GROUP BY orders.order_date) AS Order_quantity;
    
-- 10. Determine the top 3 most ordered pizza types based on revenue.

SELECT 
    Pizza_types.name,
    SUM(order_details.quantity * pizzas.price) AS Revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY revenue DESC
LIMIT 3;

-- 11. Calculate the percentage contribution of each pizza type to total revenue.

SELECT 
    pizza_types.category,
    ROUND(SUM(order_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(order_details.quantity * Pizzas.price),
                                2) AS total_sales
                FROM
                    order_details
                        JOIN
                    pizzas ON pizzas.pizza_id = order_details.pizza_id) * 100,
            2) AS revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    order_details ON order_details.pizza_id = Pizzas.pizza_id
GROUP BY pizza_types.category
ORDER BY revenue DESC;

-- 12 Analyze the cumulative revenue generated over time.
select order_date, sum(revenue) over(order by order_date) as cum_revenu
from 
(select orders.order_date,
sum(order_details.quantity * Pizzas.price) as revenue 
from order_details join pizzas
on order_details.pizza_id = pizzas.pizza_id
join orders
on orders.order_id = order_details.order_id
group by orders.order_date) as Sales;

-- 13. Determine the top 3 most ordered pizza types based on revenue for each pizza category.

SELECT name, revenue
FROM (
    SELECT 
        pizza_types.category, 
        pizza_types.name, 
        SUM(order_details.quantity) * pizzas.price AS revenue,
        RANK() OVER (PARTITION BY pizza_types.category ORDER BY SUM(order_details.quantity) * pizzas.price DESC) AS rn
    FROM pizza_types
    JOIN pizzas
        ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN order_details
        ON order_details.pizza_id = pizzas.pizza_id
    GROUP BY pizza_types.category, pizza_types.name, pizzas.price
) AS ranked_data
WHERE rn <= 3;

