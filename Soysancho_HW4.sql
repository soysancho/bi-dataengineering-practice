/*Exercise 4		--JOINS--
1.	Find the Customer who has placed the maximum no. of orders
2.	Find the Employee who has handled most no. of customers
3.	List of Shipment Company name who has shipped orders from highest to lowest along with no. of orders

*/

use Northwind_SPP

	--1--
select top(1) c.CompanyName as 'Company with max. number of orders'
	,o.CustomerID as 'ID'
	,COUNT(EmployeeID) as OrderAmount
from Customers c
join Orders o
on c.CustomerID = o.CustomerID
group by c.CompanyName, o.CustomerID
order by OrderAmount desc



	--2--
select CONCAT(e.FirstName, ' ', e.LastName) as 'Employee'
	,COUNT(o.EmployeeID) as 'Amount of served customers'
from Employees e
join Orders o
on e.EmployeeID = o.EmployeeID
group by e.FirstName, e.LastName, o.EmployeeID
order by COUNT(o.EmployeeID) desc


	--3--
select s.CompanyName as 'Shipping company'
	,COUNT(o.Freight) as 'Number of fulfilled orders'
from Shippers s
join Orders o
on s.ShipperID = o.ShipVia
group by s.CompanyName
order by COUNT(o.Freight) desc

