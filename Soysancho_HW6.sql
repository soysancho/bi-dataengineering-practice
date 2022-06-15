/*Exercise 6
1) Return a list of business units in related with each other with parent/child properties
2) Find the Business Units that come under Channel Sales & Marketing
3) Find the BU which do no have a sub unit or child unit 
4) Find the Top most BU in the hierarchy 
5) Find the total no. of child for each parent.
	i.e Find the count of BU for each parent BU
6) Use String Functions where ever applicable

*/

use Northwind_SPP

Create Table OrganizationalStructures (
 BusinessUnitID smallint identity(1,1),
 BusinessUnit varchar(100) Not Null,
 ParentUnitID smallint
)
insert into OrganizationalStructures values
('Adventure Works Cycle',NULL),
('Customer          Care',1),
('Service',1),
('Channel Sales & Marketing',1),
('Customer Support',2),
('OEM Support',2),
('              Central Region',3),
('Eastern Region',3),
('Western Region',3),
('OEM',4),
('Channel Marketing          ',4),
('National Accounts',4),
('Channel Field Sales',4),
('National           Channel Marketing',11),
('Retail Channel Marketing',11),
('Central Region',13),
('Eastern Region',13),
('Western Region',13),
('Bicycles',15),
('Bicycle Parts',15)

	--1--
;with Sancho_cte as
	(select *
		from OrganizationalStructures)
select s.BusinessUnitID as Parent_ID
		,trim(s.BusinessUnit) as Parent
		,trim(o.BusinessUnit) as Child
		,o.BusinessUnitID as Child_ID
from OrganizationalStructures o
left join Sancho_cte s
on o.ParentUnitID = s.BusinessUnitID


	--2--
;with Sancho_cte as
	(select *
		from OrganizationalStructures)
select trim(o.BusinessUnit) as 'Business Units under Channel Sales&Marketing only'
from OrganizationalStructures o
left join Sancho_cte s
on o.ParentUnitID = s.BusinessUnitID
where s.BusinessUnit = 'Channel Sales & Marketing'


	--3--
;with Sancho_cte as
	(select *
		from OrganizationalStructures)
select BusinessUnit as 'BU with no Parent or Child'
from OrganizationalStructures
except
select distinct trim(s.BusinessUnit) as Parent
from OrganizationalStructures o
join Sancho_cte s
on o.ParentUnitID = s.BusinessUnitID
where s.ParentUnitID is not null


	--4--
create function Nth_MostChildrenOwner(@nomero int)
returns table as
return
	with Sancho_cte as
		(select *
			from OrganizationalStructures)
select *
from (select trim(s.BusinessUnit) as ParentsWithChildren
			,COUNT(s.BusinessUnit) as ChildrenAmount
			,DENSE_RANK() over(order by COUNT(s.BusinessUnit) desc) as MostChildrenOwnerRank
		from OrganizationalStructures o
		join Sancho_cte s
			on o.ParentUnitID = s.BusinessUnitID
		group by s.BusinessUnit) TopChildRank
where MostChildrenOwnerRank = @nomero
--------------------------------------
select *
from Nth_MostChildrenOwner(1)
--REPLACE 1 TO ANOTHER NUMBER (MAX. 3) TO GET N-th MOST CHILDREN OWNER


	--5--
;with Sancho_cte as
		(select *
		from OrganizationalStructures)
select s.BusinessUnitID
		,trim(s.BusinessUnit) as ParentsWithChildren
		,COUNT(s.BusinessUnit) as ChildrenAmount
from OrganizationalStructures o
join Sancho_cte s
	on o.ParentUnitID = s.BusinessUnitID
group by s.BusinessUnit, s.BusinessUnitID
order by ChildrenAmount desc
