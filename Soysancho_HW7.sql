/*Exercise 7

1)	Find the Third Max Priced Product 
2)	Find which Product was sold the most on each Order date
3)	Find the Rank of mostly used Shipment for the Products
4)	Display the Avg Price against each record
5)	Find the highest price of Discontinued Products
6)	Write a Query to make sure no duplicates are in the Products table
7)	Find the top 3 products per category by list prices

*/

use Northwind_SPP


	--1--
create function MaxPricedProduct(@NthMaxPrice int)
returns table as
return
	select *
	from (select ProductID
				,ProductName
				,UnitPrice
				,row_number() over(order by unitprice desc) NthMaxPrice
				from Products) maxpriced
	where NthMaxPrice = @NthMaxPrice
------------------------------------------------------
select *
from MaxPricedProduct(3)
--REPLACE 3 TO ANOTHER NUMBER TO GET THE N-th MAX PRICED PRODUCT

	--2--
create function Nth_top_sale_of_the_day (@rank_number int)
	returns table as
	return
		select *
		from (select p.ProductName
					,o.OrderDate
					,od.Quantity
					,DENSE_RANK() 
					over(partition by orderdate order by quantity desc) as 'Number top sale of the day'
					from Products p
					join OrderDetails od
						on p.ProductID = od.ProductID
					join Orders o
						on od.OrderID = o.OrderID) day_sell_rank
		where Top_sold_item_of_the_day = @rank_number;
----------------------------------------------------------
select *
from Nth_top_sale_of_the_day(2)		
--REPLACE 1 TO 2/3/ETC (MAX. 9) TO GET THE N-th MOST SOLD PRODUCT OF EACH DAY 


	--3--
create function Nth_mostly_used_shipper(@TopUsedRank int)
returns table as
return
select *
from (select *
			,ROW_NUMBER() over(order by Number_of_shipments desc) as Top_mostly_used_shipper
		from (select top(1000) sh.CompanyName
							,COUNT(sh.CompanyName) as Number_of_shipments
				from Orders o
				join Shippers sh
					on o.ShipVia = sh.ShipperID
				group by sh.CompanyName
				order by Number_of_shipments desc) ShipperCount
	) MostlyUsedShipper
where Top_mostly_used_shipper = @TopUsedRank
--------------------------------------------------
select *
from Nth_mostly_used_shipper(1)		
--REPLACE 1 TO 2 or 3 (as there are just 3 shippers) TO GET THE N-th MOSTLY USED SHIPPER


	--4--
select p.ProductName
		,c.CategoryName
		,p.UnitPrice
		,round(AVG(p.UnitPrice) over(partition by c.categoryid), 2) AveragePrice_in_TheCategory
from Products p
join Categories c
	on p.CategoryID = c.CategoryID
order by c.CategoryName, p.UnitPrice desc


	--5--
create function Nth_pricy_discontinued_product(@ExpensiveDisc int)
returns table as
return
	select *
	from (select top(1000) ProductName
				,UnitPrice
				,ROW_NUMBER() over(order by unitprice desc) as Most_expensive_rank
			from Products
			where Discontinued = 1 --@ExpensiveDisc
			order by UnitPrice desc) DiscontinueCount
	where Most_expensive_rank = @ExpensiveDisc
--------------------------------------------------------
select *
from Nth_pricy_discontinued_product(1)
--REPLACE 1 TO ANOTHER NUMBER (MAX. 8) TO GET THE N-th MOST EXPENSIVE DISCONTINUED PRODUCT


	--6--
select distinct *
from Products


	--7--
create function N_most_pricy_products_in_each_category(@son int)
returns table as
return
	select *
	from (select p.ProductName
			,c.CategoryName
			,p.UnitPrice
			,DENSE_RANK() over(partition by c.categoryid order by unitprice desc) Rank_by_price
		  from Products p
		  join Categories c
			on p.CategoryID = c.CategoryID) PricyProduct
	where Rank_by_price between 1 and @son
-----------------------------------------------
select *
from N_most_pricy_products_in_each_category(3)