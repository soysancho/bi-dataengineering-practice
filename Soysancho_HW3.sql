/*Exercise 3
Execute the Part1_SQLPracticeProblems_SQLServer_PracticeDBSetup for the homework.
USE Northwind_SPP
1)	List the Cities and Countries of Both Customer and Employee
2)	Identify the Employees that can come to ‘Around the Horn’ in UK
3)	Find the CompanyName that have orders ordered in the year 2016
*/

use Northwind_SPP

	--1--
select CONCAT(City, ', ', Country) as 'Customer is from'
from Customers

select CONCAT(City, ', ', Country) as 'Employee is from'
from Employees


	--2--
select distinct concat(e.FirstName, ' ', e.LastName) as 'Employee', o.ShipName as 'can come to'
from Employees e
join Orders o
on e.EmployeeID = o.EmployeeID
where o.ShipName = 'Around the Horn' and o.ShipCountry = 'UK'


	--3--
select c.CompanyName, o.OrderDate as 'Only 2016 orders'
from Customers c
join Orders o
on c.CustomerID = o.CustomerID
where year(o.OrderDate) = 2016 

