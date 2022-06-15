/*Exercise 5
1)	Find orders where order amount (quantity*price*discount%) exists between 500 and 2000
2)	Find the Bill amount paid by each customer so far
3)	Find what all the ‘Beverages’ product that are available at Suppliers
		a.	Return Supplier Name, ProductName
4)	Find the Customer who has not made any orders yet.
*/

use Northwind_SPP

	--1--
select c.CompanyName
	,p.ProductName
	,od.Quantity
	,od.UnitPrice
	,od.Discount*100 as 'Discount, %'
	,od.UnitPrice*od.Quantity as 'Total sum without discount'	
	,cast(od.UnitPrice*od.Quantity*(1-od.Discount) as money) as 'Total sum with discount'
from Customers c
join Orders o
	on c.CustomerID = o.CustomerID
join OrderDetails od
	on o.OrderID = od.OrderID
join Products p
	on od.ProductID = p.ProductID
where od.UnitPrice*od.Quantity*(1-od.Discount) between 500 and 2000	-- CONSIDERING DISCOUNT
order by od.UnitPrice*od.Quantity*(1-od.Discount) desc



	--2--
				--DETAILED--
select c.CompanyName
	,p.ProductName
	,od.Quantity
	,od.UnitPrice
	,cast(od.UnitPrice*od.Quantity as money) as 'Total sum, NO discount'
	,cast(sum(od.UnitPrice*od.Quantity) over(partition by c.CompanyName) as money) as 'Total paid bill'
from Customers c
join Orders o
	on c.CustomerID = o.CustomerID
join OrderDetails od
	on o.OrderID = od.OrderID
join Products p
	on od.ProductID = p.ProductID
order by c.CompanyName


			--JUST TOTAL AMOUNT--
select c.CompanyName
	,cast(sum(od.Quantity*od.UnitPrice) as money) as 'Total paid bill'
from Customers c
join Orders o
	on c.CustomerID = o.CustomerID
join OrderDetails od
	on o.OrderID = od.OrderID
join Products p
	on od.ProductID = p.ProductID
group by c.CompanyName
order by c.CompanyName


	--3--
select s.CompanyName
	,p.ProductName
	,c.CategoryName
from Suppliers s
join Products p
	on s.SupplierID = p.SupplierID
join Categories c
	on p.CategoryID = c.CategoryID
where c.CategoryID = 1


	--4--
select CompanyName as 'Company with NO order yet'
	,CustomerID as ID
	,CONCAT(Address, ', ', City, ', ', Country) as Address
from Customers
where CustomerID not in
					(select distinct CustomerID
						from Orders)