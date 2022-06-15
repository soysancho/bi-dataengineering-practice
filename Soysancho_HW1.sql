use master

drop database if exists WorkSchedule
create database WorkSchedule
use WorkSchedule

Drop table if exists Locations
Create table Locations
(	LocationID int Primary Key,
	Name nvarchar(50),
	Street nvarchar(50),
	City nvarchar(30),
	Province varchar(2),
	Contact nvarchar(50),
	Phone char(12),
	Active bit
)

Drop table if exists Skills
Create table Skills
(	SkillID int Primary Key,
	Description nvarchar(100),
	RequiresTicket bit
)

Drop table if exists PlacementContracts
Create table PlacementContracts
(	PlacementContractID int Primary Key,
	LocationID int Foreign Key references Locations(LocationID),
	StartDate date,
	EndDate date,
	Title nvarchar(64),
	Requirements nvarchar(256),
	Cancellation datetime,
	Reason nvarchar(200)
)

Drop table if exists ContractSkills
Create table ContractSkills
(	ContractID int Primary Key,
	SkillID int Foreign Key references Skills(SkillID),
	NumberOfEmployees tinyint
)

Drop table if exists Shifts
Create table Shifts
(	ShiftID int Primary Key,
	PlacementContractID int Foreign Key references PlacementContracts(PlacementContractID),
	DayOfWeek int,
	StartTime time,
	EndTime time,
	NumberOfEmployees tinyint,
	Active bit,
	Notes nvarchar(100)
)

Drop table if exists Employees
Create table Employees
(	EmployeeID int Primary Key,
	FirstName nvarchar(50),
	LastName nvarchar(50),
	HomePhone char(12),
	Active bit
)

Drop table if exists Schedules
Create table Schedules
(	ScheduleID int Primary Key,
	Day date,
	ShiftID int Foreign Key references Shifts(ShiftID),
	EmployeeID int Foreign Key references Employees(EmployeeID)
)

Drop table if exists EmployeeSkills
Create table EmployeeSkills
(	EmployeeSkillID int Primary Key,
	EmployeeID int Foreign Key references Employees(EmployeeID),
	SkillID int Foreign Key references Skills(SkillID),
	Level int,
	YearsOfExperience int
)

select * from Locations
select * from Skills
select * from PlacementContracts
select * from ContractSkills
select * from Shifts
select * from Employees
select * from Schedules
select * from EmployeeSkills
