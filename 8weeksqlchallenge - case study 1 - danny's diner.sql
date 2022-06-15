--https://8weeksqlchallenge.com/case-study-1/
/*
drop database if exists dannys_diner
create database dannys_diner
use dannys_diner

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
*/
/* --------------------
   Case Study Questions
   --------------------*/
-- 1. What is the total amount each customer spent at the restaurant?
with [total spent by each customer] as
(select s.customer_id, product_name,
		count(s.product_id) [how many times bought],
		price,
		count(s.product_id)*price [spent on this product]
from sales s
join menu m
on s.product_id = m.product_id
group by customer_id, product_name, s.product_id, price)

select customer_id, product_name,
		[spent on this product],
		sum([spent on this product]) over(partition by customer_id order by customer_id) [total spent by the customer]
from [total spent by each customer]
---------------------------------------------------------------------------------------------------------------------------

-- 2. How many days has each customer visited the restaurant?
select  customer_id, count(distinct(order_date)) [number of days visited]
from sales
group by customer_id
order by customer_id
---------------------------------------------------------------------------------------------------------------------------

-- 3. What was the first item from the menu purchased by each customer?
create procedure [sp Nth purchased item] (@order int)
as
begin
	with [cte Nth purchased item] as
	(select customer_id, product_name, order_date,
			row_number() over(partition by customer_id order by order_date) [purchase rank]
	from sales s
	join menu m
	on s.product_id = m.product_id
	)
		select customer_id, product_name, [purchase rank]
		from [cte Nth purchased item]
		where [purchase rank] = @order
		order by customer_id, order_date
end

exec [sp Nth purchased item] 1
---------------------------------------------------------------------------------------------------------------------------

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
-- 5. Which item was the most popular for each customer?
with [max purchased times of the item] as
(select s.customer_id, product_name,
		count(s.product_id) [how many times bought],
		dense_rank() over(partition by customer_id order by count(s.product_id) desc) [rank by times purchased]
from sales s
join menu m
on s.product_id = m.product_id
group by customer_id, product_name, s.product_id, price)

select customer_id, product_name as [the most purchased item], [how many times bought]
from [max purchased times of the item]
where [rank by times purchased] = 1
---------------------------------------------------------------------------------------------------------------------------

-- 6. Which item was purchased first by the customer after they became a member?
select distinct(coalesce(mm.customer_id, 'C')) as [customer],
		coalesce(cast(join_date as varchar(20)), 'has not joined yet' )as [became a member on],
		product_name [item bought after membership]
		,CONCAT(cast(datename(m, join_date) as varchar(10)), ' ', cast(day(join_date) as varchar(2))) as  join_date
		,CONCAT(cast(datename(m, order_date) as varchar(10)), ' ', cast(day(order_date) as varchar(2))) as order_date
		
from sales s 
left join members mm 
on s.customer_id = mm.customer_id
right join menu m
on m.product_id = s.product_id
where order_date > join_date	
order by [customer]
---------------------------------------------------------------------------------------------------------------------------

-- 7. Which item was purchased just before the customer became a member?
select distinct(s.customer_id),
		product_name
		,CONCAT(cast(datename(m, join_date) as varchar(10)), ' ', cast(day(join_date) as varchar(2))) as  [join date]
		,CONCAT(cast(datename(m, order_date) as varchar(10)), ' ', cast(day(order_date) as varchar(2))) as [ordered before join]
from sales s
join members mm
on s.customer_id = mm.customer_id
join menu m
on s.product_id = m.product_id
where order_date < join_date
---------------------------------------------------------------------------------------------------------------------------

-- 8. What is the total items and amount spent for each member before they became a member?
with [cte money spent before membership] as (
select s.customer_id
		,product_name [product]
		,COUNT(s.product_id) [times was bought]
		,COUNT(s.product_id)*price [total spent on it]
from sales s
join members mm
on s.customer_id = mm.customer_id
join menu m
on s.product_id = m.product_id
--where order_date < join_date
group by s.customer_id, product_name, price
)

select customer_id, product, [times was bought], [total spent on it]
		,sum([total spent on it]) over(partition by customer_id order by customer_id) [total money spent before membership]
from [cte money spent before membership]

-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with [cte points] as (
select s.customer_id
		,product_name [product]
		,COUNT(s.product_id) [times was bought]
		,COUNT(s.product_id)*price as [total money spent on it]
from sales s
join menu m
on s.product_id = m.product_id
group by s.customer_id, product_name, price
)

select customer_id, [product], [times was bought], [total money spent on it]
		,case 
			when [product] = 'sushi' then [total money spent on it]*20
				else [total money spent on it]*10
			end as [points]
		,sum([points]) over(partition by customer_id order by customer_id)
		,avg([points]) filter
from [cte points]

-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
--		not just sushi - how many points do customer A and B have at the end of January?

select *
from menu
select *
from members
select *
from sales





