use AdventureWorks2019
go

select * from Person.Person
select * from HumanResources.Employee


--use EXCEPT to find everyone from person table that isn't in the employee table
select BusinessEntityID, FullName=dbo.udfFormattedFullName(BusinessEntityID)
from Person.Person
except
select BusinessEntityID, FullName=dbo.udfFormattedFullName(BusinessEntityID)
from HumanResources.Employee

/*use INTERSECT to find everyone in person table that is also in the employee table
	not super-useful here, just practice*/
select BusinessEntityID, FullName=dbo.udfFormattedFullName(BusinessEntityID)
from Person.Person
intersect
select BusinessEntityID, FullName=dbo.udfFormattedFullName(BusinessEntityID)
from HumanResources.Employee


/*Use UNION to combine the results of two queries. Since all results from the
	employee table are also in the person table, and the UNION operator 
	doesn't allow duplicates, the results here are identical to just 
	running the person query*/
select BusinessEntityID, FullName=dbo.udfFormattedFullName(BusinessEntityID)
from Person.Person
union
select BusinessEntityID, FullName=dbo.udfFormattedFullName(BusinessEntityID)
from HumanResources.Employee

/*Use UNION ALL to combine the results of two queries. In this case there are 
	now 290 duplicates since UNION ALL allows duplicates.*/
select BusinessEntityID, FullName=dbo.udfFormattedFullName(BusinessEntityID)
from Person.Person
union all
select BusinessEntityID, FullName=dbo.udfFormattedFullName(BusinessEntityID)
from HumanResources.Employee
