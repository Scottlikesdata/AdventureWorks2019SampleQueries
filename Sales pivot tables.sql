--creating pivot tables of sales by territory and group/territory

--Select statement referencing the pivot table
select pvt.Territory
	,format(pvt.[2011],'c','en-us') as [2011 Sales]
	,format(pvt.[2012],'c','en-us') as [2012 Sales]
	,format(pvt.[2013],'c','en-us') as [2013 Sales]
	,format(pvt.[2014],'c','en-us') as [2014 Sales]
from
--source query to grab the data that will be pivoted
(
select year(soh.OrderDate)as OrderYear, soh.SubTotal, st.[Name] as Territory
from Sales.SalesOrderHeader as soh
	left join Sales.SalesTerritory as st
	on soh.TerritoryID = st.TerritoryID
) as src
--pivot expression
pivot
(
	Sum(SubTotal)
	For [OrderYear]
	In ([2011],[2012],[2013],[2014]) 
)as pvt
order by Territory

--the same query, but with the addition of the Group field
select pvt.[Group], pvt.Territory 
	,format(pvt.[2011],'c','en-us') as [2011 Sales]
	,format(pvt.[2012],'c','en-us') as [2012 Sales]
	,format(pvt.[2013],'c','en-us') as [2013 Sales]
	,format(pvt.[2014],'c','en-us') as [2014 Sales]
from
(
select year(soh.OrderDate)as OrderYear, soh.SubTotal, st.[Name] as Territory, st.[Group]
from Sales.SalesOrderHeader as soh
	left join Sales.SalesTerritory as st
	on soh.TerritoryID = st.TerritoryID
) as src
pivot
(
	Sum(SubTotal)
	For [OrderYear]
	In ([2011],[2012],[2013],[2014]) 
)as pvt
--now it's ordered by Group then Territory
order by [Group],Territory

