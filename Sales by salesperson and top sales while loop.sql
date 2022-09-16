use AdventureWorks2019

/*****tables used for the following queries*****/
select * from Sales.SalesOrderHeader
select * from Sales.SalesPerson
select * from Sales.SalesTerritory
select * from Person.Person
go

/*********Return sales order info by salesperson and order date************/
--this is the initial query that subsequent queries will build upon
select concat(p.LastName,', ', p.FirstName, isnull(concat(' ',p.MiddleName),'')) as SalesPersonName
	,format(soh.SubTotal,'c','en-us') as OrderSubtotal, format(soh.OrderDate,'yyyy/MM/dd') as OrderDate
from Sales.SalesOrderHeader as soh
left join Sales.SalesPerson as sp
	on soh.SalesPersonID = sp.BusinessEntityID
left join Sales.SalesTerritory as st
	on sp.TerritoryID = st.TerritoryID
left join Person.Person as p
	on p.BusinessEntityID = soh.SalesPersonID
go

/**********return sales totals for salesperson and territory for a given time period.
		This query also assigns "Website" to missing salesperson names and "Home Office" 
		to missing territories. Two options are considered for limiting the time period.***********/
select case when p.LastName is null then 'Website'
		else concat(p.LastName,', ', p.FirstName, isnull(concat(' ',p.MiddleName),''))
		 end as SalesPersonName
	,case when st.[Name] is null then 'Home Office'
		else st.[Name] end as Territory
	,count(soh.SubTotal) as Orders
	,format(sum(soh.SubTotal),'c','en-us') as SumOrderSubtotals
from Sales.SalesOrderHeader as soh
left join Sales.SalesPerson as sp
	on soh.SalesPersonID = sp.BusinessEntityID
left join Sales.SalesTerritory as st
	on sp.TerritoryID = st.TerritoryID
left join Person.Person as p
	on p.BusinessEntityID = soh.SalesPersonID
--many resources say to not use functions in the where clause, but the execution
--plan for this query using year() is identical to the commented out version and 
--since it's shorter and more obvious in this case I prefer it all other things
--being equal.
where year(soh.OrderDate) = 2014
--where soh.OrderDate > '20140101' and soh.OrderDate < '20150101'
group by case when p.LastName is null then 'Website'
		else concat(p.LastName,', ', p.FirstName, isnull(concat(' ',p.MiddleName),''))
		 end, st.[Name]
--sum(soh.SubTotal) is used in the order by because the currency formatted
--version will sort as text rather than numerically
order by sum(soh.SubTotal) desc
go

/*********Find top 2 sales for each salesperson using while loop*********/
--declare variable and set it to minimum salesperson ID
declare @counter int = (select min(soh.SalesPersonID) from Sales.SalesOrderHeader as soh)
--create empty temp table from the select statement that will be used to populate it
drop table if exists #tempresults 
select isnull(soh.SalesPersonID,999) as SalesPersonID,
case when p.LastName is null then 'Website'
		else concat(p.LastName,', ', p.FirstName, isnull(concat(' ',p.MiddleName),''))
		 end as SalesPersonName
	,format(soh.SubTotal,'c','en-us') as OrderSubtotal, format(soh.OrderDate,'yyyy/MM/dd') as OrderDate
into #tempResults
from Sales.SalesOrderHeader as soh
left join Sales.SalesPerson as sp
	on soh.SalesPersonID = sp.BusinessEntityID
left join Sales.SalesTerritory as st
	on sp.TerritoryID = st.TerritoryID
left join Person.Person as p
	on p.BusinessEntityID = soh.SalesPersonID
where 1 = 2

--establish stopping point for while loop
while @counter <= (select max(soh.SalesPersonID) from Sales.SalesOrderHeader as soh)
--main body of query to return top 2 sales for each salesperson
begin
insert into #tempResults
select top 2 isnull(soh.SalesPersonID,999) as SalesPersonID,
case when p.LastName is null then 'Website'
		else concat(p.LastName,', ', p.FirstName, isnull(concat(' ',p.MiddleName),''))
		 end as SalesPersonName
	,format(soh.SubTotal,'c','en-us') as OrderSubtotal, format(soh.OrderDate,'yyyy/MM/dd') as OrderDate
from Sales.SalesOrderHeader as soh
left join Sales.SalesPerson as sp
	on soh.SalesPersonID = sp.BusinessEntityID
left join Sales.SalesTerritory as st
	on sp.TerritoryID = st.TerritoryID
left join Person.Person as p
	on p.BusinessEntityID = soh.SalesPersonID
where SalesPersonID = @counter
order by soh.SubTotal desc
set @counter = @counter + 1
end
--report the results
select SalesPersonName, OrderSubtotal, OrderDate from #tempresults