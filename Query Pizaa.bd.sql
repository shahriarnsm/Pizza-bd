CREATE SCHEMA pizza_bd;

DROP TABLE IF EXISTS runners;

CREATE TABLE runners (
  runner_id INTEGER,
  registration_date DATE
);

INSERT INTO runners
  (runner_id, registration_date)
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  order_id INTEGER,
  customer_id INTEGER,
  pizza_id INTEGER,
  exclusions VARCHAR(4),
  extras VARCHAR(4),
  order_time TIMESTAMP
);

INSERT INTO customer_orders
  (order_id, customer_id, pizza_id, exclusions, extras, order_time)
VALUES
  ('1', '101', '1', NULL, NULL,  '2020-01-01 18:05:02'),
  ('2', '101', '1', NULL, NULL, '2020-01-01 19:00:52'),
  ('3', '102', '1', NULL, NULL,  '2020-01-02 23:51:23'),
  ('3', '102', '2', NULL, NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', NULL,  '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', NULL,  '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', NULL,  '2020-01-04 13:23:46'),
  ('5', '104', '1', NULL, '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', NULL, NULL,  '2020-01-08 21:03:13'),
  ('7', '105', '2', NULL, '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', NULL, NULL,  '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', NULL, NULL,  '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  order_id INTEGER,
  runner_id INTEGER,
  pickup_time VARCHAR(19),
  distance VARCHAR(7),
  duration VARCHAR(10),
  cancellation VARCHAR(23)
);

INSERT INTO runner_orders
  (order_id, runner_id, pickup_time, distance, duration, cancellation)
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', NULL),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', NULL),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', NULL, NULL, NULL, 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', NULL),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', NULL),
  ('9', '2', NULL, NULL, NULL, 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', NULL);


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  pizza_id INTEGER,
  pizza_name TEXT
);
INSERT INTO pizza_names
  (pizza_id, pizza_name)
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');

DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  pizza_id INTEGER,
  toppings INTEGER
);

INSERT INTO pizza_recipes
  (pizza_id, toppings)
VALUES
  (1, 1),(1, 2),(1, 3),(1, 4),(1, 5),(1, 6),(1, 8),(1, 10),(2, 4),(2, 6),(2, 7),(2, 9),(2, 11),(2, 12);


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  topping_id INTEGER,
  topping_name TEXT
);
INSERT INTO pizza_toppings
  (topping_id, topping_name)
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');










-- 1.How many pizzas were ordered?
select
    count(order_id)
from customer_orders;


-- 2.How many unique customer orders were made?
select
    count(distinct customer_id)
from customer_orders;


-- 3.How many successful orders were delivered by each runner?
select
    runner_id,
    count(co.order_id)
from customer_orders as co
inner join runner_orders as ro on co.order_id = ro.order_id
where cancellation is null
group by runner_id;


-- 4.How many of each type of pizza was delivered?
select
    pizza_name,
    count(co.order_id) as Total_Pizza_Sold
from customer_orders as co
    inner join pizza_names pn on co.pizza_id = pn.pizza_id
inner join runner_orders as ro on co.order_id = ro.order_id
where cancellation is null
group by pizza_name;


-- 5.How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id, pizza_name, count(pn.pizza_name)as order_count
from customer_orders
inner join pizza_names pn on customer_orders.pizza_id = pn.pizza_id
group by customer_id, pizza_name
order by customer_id asc;


-- 6.What was the maximum number of pizzas delivered in a single order?
select c.order_id,
       count(c.pizza_id) as count,
       order_time
from customer_orders as c
    inner join runner_orders ro on c.order_id = ro.order_id
where ro.cancellation is null
group by c.order_id, order_time
order by count desc
limit 1;


-- 7.For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select c.customer_id,
       count(case when exclusions is null and extras is null then c.order_id end) as no_change,
       count(case when exclusions is not null or extras is not null then c.order_id end) has_change
from customer_orders as c
inner join runner_orders ro on c.order_id = ro.order_id
where ro.cancellation is null
group by customer_id;


-- 8.How many pizzas were delivered that had both exclusions and extras?
select count(c.order_id)
from customer_orders as c
inner join runner_orders ro on c.order_id = ro.order_id
where ro.cancellation is null
and c.exclusions and c.extras is not null;


-- 9.What was the total volume of pizzas ordered for each hour of the day?
select year, month, day,hour,
       count(order_id) as order_count
from
(select order_time,
        year(order_time) as 'year',
        month(order_time) as 'month',
       -- day(order_time) as 'date',
       dense_rank() over (order by date(order_time)asc) as day,
       hour(order_time) as 'hour',
       order_id
from customer_orders) as t
group by year, month, day, hour;


-- 10.What was the volume of orders for each day of the week? 1 week = 3 days

-- short length query
select week,
       count(order_id)as order_count
from
(select*, date(order_time) as 'date',
       dense_rank() over (order by day(order_time)asc ) as day,
       ceiling(dense_rank() over (order by day(order_time)asc )/3)as week
from customer_orders) as t
group by week;



-- sub query system
select weeks,
       week_days,
       count(order_id) as order_count
from
(select *,
       dense_rank() over (partition by weeks order by days asc ) as week_days
from
(select *, date(order_time) as 'date',
       dense_rank() over (order by day(order_time)asc ) as days,
       ceiling(dense_rank() over (order by day(order_time)asc )/3)as weeks
from customer_orders) as t) as t2
group by weeks,week_days;