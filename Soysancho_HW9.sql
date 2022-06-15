/*Exercise 9

Create TVF
1.	Create an iTVF which finds the Female Staffs in the Organization
	a.	Input Parameter – Gender (M/F)
	b.	Output Parameter – List of all female employees
2.	Create an iTVF to find Products which has no.of available units greater than the input provided
	a.	Input Parameter – Units interger
	b.	Output – ProductID, ProductName, UnitAvailable
3.	Create a MSTVF to find the lastShipped Order Details
	a.	Input Parameter – CustomerID
	b.	Output – Orderid, CustomerID, Orderdate, OrderQuantity

*/

use Northwind_SPP


	--1--
			--Let's create a column Gender to ease subsequent steps
alter table employees
add Gender char(6)
			--Then set everybody's genders
update Employees
set Gender = 'Female'
where TitleOfCourtesy in ('Ms.', 'Mrs.')

update Employees
set Gender = 'Male'
where TitleOfCourtesy = 'Mr.'

update Employees
set Gender = 'N/A'
where TitleOfCourtesy not in ('Mr.', 'Ms.', 'Mrs.')
				--Let's create a function
create function ChooseGender(@gender char(1))
returns table as
return
	select EmployeeID
			,CONCAT(TitleOfCourtesy, ' ', FirstName, ' ', LastName) as Employee
			,Gender
			,Title
	from Employees
	where Gender = case @gender
					when 'm' then 'Male'
					when 'f' then 'Female'
					else 'N/A'
					end
----------------------------------------------
select *
from ChooseGender('m') --Chooses all the males
select *
from ChooseGender('f') --Chooses all the females
select *
from ChooseGender('jhkebkjsad') --Input is random


	--2--
create function MoreStockedUnitsThanThis(@chislo int)
returns table as
return
	select ProductID
			,ProductName
			,UnitsInStock
	from Products
	where UnitsInStock > @chislo
--	order by UnitsInStock desc
----------------------------------------------------------
select *
from MoreStockedUnitsThanThis(100)
order by UnitsInStock desc


	--3--
			--FIRST CHECK THIS ONE WHICH RETURNS
			--ALL THE LATEST ORDER(S) OF ALL CUSTOMERS
select *
from (select o.OrderID
		,o.CustomerID
		,o.OrderDate
		,od.Quantity
		,p.ProductName
		,sh.CompanyName
		,DENSE_RANK() over(partition by CustomerID order by OrderDate desc) OrderRank
from Orders o
join OrderDetails od
	on o.OrderID = od.OrderID
join Products p
	on od.ProductID = p.ProductID
join Shippers sh
	on o.ShipVia = sh.ShipperID) sss
where OrderRank = 1
--------------------------------------------------------------------

				--THEN CREATE A FUNCTION WHICH RETURNS
				--THE LATEST ORDER(S) DETAILS
				--OF AN EXACT CUSTOMER
create function LastShippedOrderDetails(@customer varchar(50))
returns table as
return
	select *
from (select o.OrderID
		,o.CustomerID
		,o.OrderDate
		,od.Quantity
		,p.ProductName
		,sh.CompanyName
		,DENSE_RANK() over(partition by CustomerID order by OrderDate desc) OrderRank
from Orders o
join OrderDetails od
	on o.OrderID = od.OrderID
join Products p
	on od.ProductID = p.ProductID
join Shippers sh
	on o.ShipVia = sh.ShipperID
	where CustomerID = @customer) sss
where OrderRank = 1
----------------------------------------------
select *
from LastShippedOrderDetails('anatr')
