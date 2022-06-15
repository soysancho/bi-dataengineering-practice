/*Exercise 8

Scalar Functions – 
	1.	Create a function to find the age of the Employees
		Input Parameters – DOB
		Output – Age, which is an integer value
			Use the function created to find the age of the employees by passing Employees.BirthDate as Input
	2.	Write a function to find the number of days after a customers last order date
		a.	Input Parameter – CustomerID
		b.	Output Parameter – No.of Days which is an integer value
			Use the function created to find the no  of days by passing Customer.CustomerId as Input
	3.	Write a function to find the avg Frequency of orders of each customer
		a.	Input Parameter – CustomerID
		b.	Output Parameter – No.of Days which is an integer value
			Use the function created to find the no  of days by passing Customer.CustomerId as Input

Views –
	1.	Create a View with following columns
		a.	Employee Name (combination of Title of Courtesy , FirstName and LastName)
		b.	ReportingManagerName
		c.	No. of Orders handled by the employee
		d.	Age of the Employee (Hint : Use the Function created from above)
		e.	No. of experience in years of the employee

*/

use Northwind_SPP

						--SCALAR FUNCTIONS--
	--1--
create function dbo.Age
(@dob datetime)
returns int
as
begin
	declare @yosh int
	set @yosh = DATEDIFF(YEAR, @dob, GETDATE()) - case
													when (MONTH(@dob) > MONTH(GETDATE()))
															or (MONTH(GETDATE()) = MONTH(@dob) and day(@dob)>day(GETDATE()))
														then 1
													else 0
													end
return @yosh
end
----------------------------------------------
select CONCAT(FirstName, ' ', LastName) as Name
		,BirthDate
		,dbo.Age(BirthDate) as Age
from Employees


	--2--
				--1st WAY - USING SCALAR FUNCTION
				--BUT INPUT IS LAST_ORDER_DATE, NOT CUSTOMER_ID
create function How_Many_Days_Since_Last_Order_SF
(@last_order_date datetime)
returns int
as
begin
	declare @number_of_days int
	set @number_of_days = DATEDIFF(DAY, @last_order_date, GETDATE())
	return @number_of_days
end
--------------------------
select *				--Listing the latest order of all the customers
from (select CustomerID
		,OrderID
		,OrderDate
		,GETDATE() as 'Current date&time'
		,dbo.How_Many_Days_Since_Last_Order_SF(OrderDate)
			as 'How many days ago this order was'
		,DENSE_RANK() over(partition by customerID order by orderdate desc) as OrderRank
		from Orders) sss
where OrderRank = 1
-----------------------------------------------------------------------------------------
				--2nd WAY - USING TABLE-VALUED FUNCTION
				--WHERE INPUT IS CUSTOMER_ID
create function How_Many_Days_Since_Last_Order_TF
(@customer_id nvarchar(max))
returns table as
return
	select *
	from (select CustomerID
			,OrderID
			,OrderDate
			,GETDATE() as 'Current date&time'
			,DATEDIFF(DAY, OrderDate, GETDATE()) as 'How many days ago this order was'
			,DENSE_RANK() over(partition by customerID order by orderdate desc) as OrderRank
			from Orders) sss
	where OrderRank = 1 and CustomerID = @customer_id
------------------------------------------------------
select *
from How_Many_Days_Since_Last_Order_TF('alfki')
----------------------------------------------------------------------------



	--3--
			--FIRST FUNCTION FINDS THE FIRST ORDER DATE
create function First_Order_Date
(@Customer_id nvarchar(max))
returns datetime
as
begin
	declare @birinchisi datetime
	set @birinchisi = (select OrderDate
					 from (select CustomerID
									,OrderDate
									,DENSE_RANK() over(partition by customerID order by orderdate)
										as FirstOrder
					from Orders) FO
					where FirstOrder = 1 and CustomerID = @Customer_id)
	return @birinchisi
end

			--SECOND FUNCTION FINDS THE LATEST ORDER DATE
create function Latest_Order_Date
(@Customer_id nvarchar(max))
returns datetime
as
begin
	declare @oxirgisi datetime
	set @oxirgisi = (select OrderDate
					 from (select CustomerID
									,OrderDate
									,DENSE_RANK() over(partition by customerID order by orderdate desc)
										as LatestOrder
					from Orders) LO
					where LatestOrder = 1 and CustomerID = @Customer_id)
	return @oxirgisi
end
------------------------
			--THEN FIND WHAT WE NEED
select CustomerID
		,dbo.First_Order_Date(CustomerID) as FirstOrderDate
		,dbo.Latest_Order_Date(CustomerID) as LatestOrderDate
		,DATEDIFF(DAY, dbo.First_Order_Date(CustomerID), dbo.Latest_Order_Date(CustomerID))
			as 'Difference between first and last orders (Days)'
		,COUNT(CustomerID) as 'Total number of orders'
		,DATEDIFF(DAY, dbo.First_Order_Date(CustomerID), dbo.Latest_Order_Date(CustomerID))/COUNT(CustomerID) 
			as 'Average order frequency (Days)'
from Orders
group by CustomerID
order by CustomerID
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------
-----------------------------------------------------------------------------------------------------------------


						--VIEWS--

			--FIRSTLY, CREATE A FUNCTION THAT WILL HELP FIND REPORTING_TO MANAGER
create function Manager
(@employee_id int)
returns nvarchar(max)
as
begin
	declare @mngr nvarchar(max)
	set @mngr = case
					when (select CONCAT(TitleOfCourtesy, ' ', FirstName, ' ', LastName)
						  from Employees
						  where EmployeeID = @employee_id) is null then 'Nobody'
					else (select CONCAT(TitleOfCourtesy, ' ', FirstName, ' ', LastName)
						  from Employees
						  where EmployeeID = @employee_id)
				end
	return @mngr
end

			--SECONDLY, CREATE A VIEW WITH REQUIRED COLUMNS
create view Sancho_view as
select top(1000)
		e.EmployeeID
		,CONCAT(e.TitleOfCourtesy, ' ', e.FirstName, ' ', e.LastName)
			as Employee_Name
		,dbo.Manager(e.ReportsTo) as ReportsTo
		,COUNT(e.EmployeeID) as Handled_Orders_Amount
		,dbo.Age(e.BirthDate) as Age
		,dbo.Age(e.HireDate) as Experience_Years
from Employees e
join Orders o
	on e.EmployeeID = o.EmployeeID
group by e.EmployeeID, e.TitleOfCourtesy, e.FirstName, e.LastName, e.ReportsTo, dbo.Age(e.BirthDate), dbo.Age(e.HireDate)
order by e.EmployeeID

			--FINALLY, CALL THE CREATED ABOVE VIEW
select *
from Sancho_view