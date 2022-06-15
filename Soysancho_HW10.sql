/*Exercise 10

Stored Procedure
1)	Create a Stored Procedure
		Update the Suppliers FAX value with corresponding PhoneNumber if not available
2)	Create a procedure to find the age of the Employees
		Input Parameters – DOB
		Output Parameter – Age, which is an integer value
		Exec the Stored Procedure by passing the Employee DOB

*/

use Northwind_SPP


	--1--

alter table Suppliers
add FaxStatus nvarchar(max)
---------------------------------------
drop view if exists Suppliers_recurse
-------------------------------------
create view Suppliers_recurse
	as
	select SupplierID	
			,CompanyName
			,Phone
			,Fax
			,FaxStatus
	from Suppliers
-------------------------------------
	select *
	from Suppliers_recurse
-------------------------------------
drop proc if exists Suppliers_FAX_upd
-------------------------------------
create proc Suppliers_Fax_upd
as
begin	
	declare @loop int
	set @loop = 1
		while @loop <= (select count(SupplierID)
						from Suppliers)
			begin
				update Northwind_SPP.dbo.Suppliers
				set FaxStatus = case 
									when Fax is null 
										then 'Changed'
									else 'Unchanged'
									end,
					Fax = case 
							when Fax is null 
								then (select s.Phone
									from Suppliers s 
									join Suppliers_recurse sr
									on sr.supplierid = s.SupplierID
									where s.SupplierID = @loop)
							else Fax
							end
				where Northwind_SPP.dbo.Suppliers.SupplierID = @loop;
				set @loop += 1
			end
	select SupplierID
			,CompanyName
			,Phone
			,Fax
			,FaxStatus
	from Suppliers
end
-----------------------
begin tran					--EXECUTE THE PROCEDURE
exec Suppliers_Fax_upd
-----------------------
rollback					--ROLLBACK  
-----------------------		--IN ORDER TO
select SupplierID			--CHECK IF EVERYTHING WAS CORRECT
		,CompanyName
		,Phone
		,Fax
		,FaxStatus
from Suppliers
-----------------------
commit						--COMMIT IN ORDER TO MAKE CHANGES IRREVERSABLE 
-----------------------
-----------------------


	--2--

-----------------------
alter table Employees
drop column Age
------------------------
alter table Employees
add Age int
------------------------
drop proc if exists EmployeesAge
------------------------
create proc EmployeesAge
as
begin
	declare @id int
	set @id = 1
	while @id <= (select COUNT(EmployeeID)
					from Employees)
		begin
			declare @dob datetime
			set @dob = (select BirthDate
						from Employees
						where EmployeeID = @id)
			update Employees
			set Age = DATEDIFF(YEAR, @dob, GETDATE()) - case
										when (MONTH(@dob) > MONTH(GETDATE()))
												or (MONTH(GETDATE()) = MONTH(@dob) and day(@dob)>day(GETDATE()))
											then 1
										else 0
										end
			where EmployeeID = @id
			set @id += 1	
		end

	select EmployeeID				
		,CONCAT(FirstName, ' ', LastName)
			as Name
		,BirthDate
		,Age
	from Employees
end
-----------------
begin tran									--EXECUTE THE PROCEDURE
exec EmployeesAge							
-----------------
rollback									--ROLLBACK  	
-----------------							--IN ORDER TO
select EmployeeID							--CHECK IF EVERYTHING WAS CORRECT
		,CONCAT(FirstName, ' ', LastName)
			as Name
		,BirthDate
		,Age
from Employees
-----------------------
commit						--COMMIT IN ORDER TO MAKE CHANGES IRREVERSABLE 
-----------------------

