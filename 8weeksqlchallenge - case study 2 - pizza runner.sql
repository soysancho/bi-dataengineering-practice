--drop database if exists pizza_runner
--create database pizza_runner
--use pizza_runner
/*
DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
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
  order_time datetime
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-02-01 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-02-01 23:51:23'),
  ('4', '103', '1', '4', '', '2020-04-01 13:23:46'),
  ('4', '103', '1', '4', '', '2020-04-01 13:23:46'),
  ('4', '103', '2', '4', '', '2020-04-01 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-08-01 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-08-01 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-08-01 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-09-01 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-10-01 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-11-01 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-11-01 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  pickup_time datetime,
  "distance_km" decimal(4,2),
  "duration_mins" int,
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance_km", "duration_mins", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20', '32', NULL),
  ('2', '1', '2020-01-01 19:10:54', '20', '27', NULL),
  ('3', '1', '2020-03-01 00:12:37', '13.4', '20', NULL),
  ('4', '2', '2020-04-01 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-08-01 21:10:57', '10', '15', NULL),
  ('6', '3', NULL, NULL, NULL, 'Restaurant Cancellation'),
  ('7', '2', '2020-08-01 21:30:45', '25', '25', NULL),
  ('8', '2', '2020-10-01 00:15:02', '23.4', '15', NULL),
  ('9', '2', NULL, NULL, NULL, 'Customer Cancellation'),
  ('10', '1', '2020-11-01 18:50:20', '10', '10', NULL);


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" varchar(30)
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" varchar(30)
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" nvarchar(50)
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
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
  */

/*


D. Pricing and Ratings
If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?
What if there was an additional $1 charge for any pizza extras?
Add cheese is $1 extra
The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.
Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
customer_id
order_id
runner_id
rating
order_time
pickup_time
Time between order and pickup
Delivery duration
Average speed
Total number of pizzas
If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
E. Bonus Questions
If Danny wants to expand his range of pizzas - how would this impact the existing data design? Write an INSERT statement to demonstrate what would happen if a new Supreme pizza with all the toppings was added to the Pizza Runner menu?
*/



					--  A. Pizza Metrics --
--How many pizzas were ordered?
select count(order_id) as [ordered pizza amount]
from customer_orders

--How many unique customer orders were made?
select count(distinct(customer_id)) as [unique customer orders]
from customer_orders

--How many successful orders were delivered by each runner?
select runner_id, count(order_id) as [successful orders]
from runner_orders
where cancellation is null
group by runner_id

--How many of each type of pizza was delivered?
select pizza_name, count(r.order_id) as [total ordered amount]
from runner_orders r
join customer_orders c
on r.order_id = c.order_id
join pizza_names p
on c.pizza_id = p.pizza_id
where cancellation is null
group by pizza_name

--How many Vegetarian and Meatlovers were ordered by each customer?
select customer_id, pizza_name, count(c.pizza_id) as [amount]
from customer_orders c
join pizza_names p
on c.pizza_id = p.pizza_id
group by customer_id, pizza_name
order by customer_id

--What was the maximum number of pizzas delivered in a single order?
with [cte max pizza deliver] as (
select order_id
		,COUNT(pizza_id) as [pizza amount]
		,ROW_NUMBER() over(order by COUNT(pizza_id) desc) [row num]
from customer_orders
group by order_id )

select order_id, [pizza amount]
from [cte max pizza deliver]
where [row num] = 1

--For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
select customer_id, count(pizza_id) [unchanged pizzas]
from customer_orders
where exclusions is null and extras is null
group by customer_id
--	union all
select customer_id, count(pizza_id) [pizzas changed at least once]
from customer_orders
where exclusions is not null or extras is not null
group by customer_id
--------------------------------------------------------------------------------------------------
-- must be worked out -- incorect --
select c.customer_id, count(c.pizza_id) [unchanged pizzas], count(j.pizza_id) [changed pizzas]
from customer_orders c
left join customer_orders j
on c.order_id = j.order_id
where (c.exclusions is null and c.extras is null)
		or (j.exclusions is not null or j.extras is not null)
group by c.customer_id


--How many pizzas were delivered that had both exclusions and extras?
select count(order_id) [both exclusions and extras number]
from customer_orders
where exclusions is not null and extras is not null

--What was the total volume of pizzas ordered for each hour of the day?
select DATEFROMPARTS(DATEPART(year, order_time), DATEPART(MONTH, order_time), DATEPART(DAY, order_time)) [date]
		,DAtEPART(hour, order_time) as [hour]
		,COUNT(order_id) [hourly volume of orders]
from customer_orders
group by DATEFROMPARTS(DATEPART(year, order_time), DATEPART(MONTH, order_time), DATEPART(DAY, order_time))
			,DAtepart(hour, order_time)
order by [date]

--What was the volume of orders for each day of the week?
select DATEFROMPARTS(DATEPART(year, order_time), DATEPART(MONTH, order_time), DATEPART(DAY, order_time)) [date]
		,DATEPART(WEEK, order_time) [week number]
		--,DATEPART(DAY, order_time) as [day of the month]
		,COUNT(order_id) [daily volume of orders]
from customer_orders
group by DATEFROMPARTS(DATEPART(year, order_time), DATEPART(MONTH, order_time), DATEPART(DAY, order_time))
			,DATEPART(WEEK, order_time)
			--,DATEPART(DAY, order_time)
order by [date]


					-- B. Runner and Customer Experience --
--How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select count(runner_id) as [number of runners registered]
		,DATEPART(WEEK, registration_date) as [week]
from runners
group by DATEPART(WEEK, registration_date)

--What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
select runner_id, AVG(duration_mins)as [avg order time]
from runner_orders
group by runner_id
order by runner_id



select *
from runner_orders
alter table runner_orders
alter column distance_km decimal(4,2)

--Is there any relationship between the number of pizzas and how long the order takes to prepare?
select r.order_id
		,DATEDIFF(MINUTE, order_time, pickup_time) [mins to prepare]
		,COUNT(pizza_id) [pizza amount]
		,DATEDIFF(MINUTE, order_time, pickup_time)/COUNT(pizza_id) [mins to make per pizza]
from runner_orders r
join customer_orders c
on r.order_id = c.order_id
group by r.order_id, DATEDIFF(MINUTE, order_time, pickup_time)
order by r.order_id

--What was the average distance travelled for each customer?
select r.order_id, distance_km, customer_id
		,cast(AVG(distance_km) over(partition by customer_id order by customer_id) as decimal(4,2))[avg travelled km's]
from runner_orders r
join customer_orders c
on r.order_id = c.order_id

--What was the difference between the longest and shortest delivery times for all orders?
select concat(MAX(duration_mins)-MIN(duration_mins), ' minutes') 
		as [difference between the longest and shortest delivery time]
from runner_orders

--What was the average speed for each runner for each delivery and do you notice any trend for these values?
select runner_id
		,cast(ROUND(avg(distance_km/duration_mins*60), 2) as decimal(4,2)) as [average speed]
from runner_orders
group by runner_id

--What is the successful delivery percentage for each runner?
create function dbo.udf_toa ()
returns table as
return
(select runner_id, COUNT(order_id) as [total order amount]
from runner_orders
group by runner_id)
----
create function dbo.udf_soa()
returns table as
return
(select runner_id, COUNT(order_id) as [successful order amount]
from runner_orders
where pickup_time is not null
group by runner_id)
----
select t.runner_id
		,concat(CAST(s.[successful order amount] as float) / CAST(t.[total order amount] as float)*100, ' %') as [success rate]
--		,s.[successful order amount]
--		,t.[total order amount]
from dbo.udf_toa() t
join dbo.udf_soa() s
on t.runner_id = s.runner_id


					--- C. Ingredient Optimisation ---
--What are the standard ingredients for each pizza?
declare @Standard_ingredients table (topping_id varchar(2))
declare @counter int = 1;
while (@counter <= (select count(topping_id) from pizza_toppings))
	begin
	 if (select COUNT(@counter) as [common]
		from (select @counter as numero, *
				from (select ROW_NUMBER() over(order by pizza_id) as [in pizza #]
						,CHARINDEX(concat(' ', CAST(@counter as varchar), ','), toppings) as [yes_no]
						from pizza_recipes) [if_exists]
				where [yes_no] > 0) aa
		group by aa.numero
		having COUNT(@counter) > 1) > 1
			begin
				insert into @Standard_ingredients values(@counter)
			end
		set @counter = @counter + 1
	end
select --s.topping_id,
		t.topping_name as [Standard ingredients]
from @Standard_ingredients s
join pizza_toppings t
on s.topping_id = t.topping_id


--What was the most commonly added extra?
select *
from customer_orders

begin tran
update customer_orders
set extras = null
where extras in ('', 'null') 
commit
rollback


--What was the most common exclusion?
--Generate an order item for each record in the customers_orders table in the format of one of the following:
--Meat Lovers
--Meat Lovers - Exclude Beef
--Meat Lovers - Extra Bacon
--Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
--Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
--For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
--What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?

select *
from runner_orders
select *
from customer_orders



begin tran
update runner_orders
set pickup_time = DATEFROMPARTS(DATEPART(year, pickup_time), DATEPART(day, pickup_time), DATEPART(month, pickup_time))
where pickup_time is not null
rollback


select *
from customer_orders




select *
from customer_orders

select *
from runner_orders

select *
from pizza_names

update customer_orders
set extras = null
where extras in (null, '', 'null')






select *
from pizza_recipes

select *
from pizza_toppings

sp_help pizza_toppings

select *
from runner_orders

select *
from runners

select *
from customer_orders

