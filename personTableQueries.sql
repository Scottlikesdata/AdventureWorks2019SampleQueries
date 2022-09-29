use AdventureWorks2019

/******select records from person table that are not in employee table*********/

--using except as a subquery and "where in" to filter person table by results
select * from Person.person
where BusinessEntityID in 
(
	select p.BusinessEntityID from Person.person as p
	except 
	select e.BusinessEntityID
	from HumanResources.Employee as e
)
order by BusinessEntityID


--using "where not in" as subquery...simpler and faster
select * from Person.Person as p
where p.BusinessEntityID not in 
	(select BusinessEntityID from HumanResources.Employee)
order by p.BusinessEntityID


/**** find everyone in the person table that has a generational suffix******/
select * from Person.person where Suffix is not null

/**** select BusinessEntityID and formatted_name that includes Title, First, Middle initial, Last and suffix *****/

select BusinessEntityID,
	concat(
		case when Title is null then '' else concat(Title,' ') end, FirstName, ' ',
		case when left(MiddleName,1) is null then '' else concat(left(MiddleName,1),'. ') end,
		LastName,
		case when Suffix is null then '' else concat(' ',Suffix) end
			) as formatted_name
from Person.Person
go

/**** This script turns the formatted name script above into a function named udfFormattedFullName
		that can be used in any query where the BusinessEntityID is available to 
		provide the formatted name with having to use the script **********/

create or alter function udfFormattedFullName(@BusinessEntityID int)
Returns nvarchar(75)
as
begin
	Declare @formattedFullName nvarchar(75)
	set @formattedFullName =
		(
		select 
		concat(
		case when Title is null then '' else concat(Title,' ') end, FirstName, ' ',
		case when left(MiddleName,1) is null then '' else concat(left(MiddleName,1),'. ') end,
		LastName,
		case when Suffix is null then '' else concat(' ',Suffix) end
			) as formattedName
		from Person.Person
		where BusinessEntityID = @BusinessEntityID)
    return @formattedFullName
end
go



