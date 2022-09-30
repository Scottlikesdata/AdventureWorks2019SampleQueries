use AdventureWorks2019

--check out the data
select * from Sales.SalesOrderHeader
go

/******** find the three day rolling average for total sales ***********/

--write query for daily averages
select format(OrderDate,'yyyy-MM-dd','en-us') as OrderDate, 
	avg(SubTotal) as DailyAvg
from Sales.SalesOrderHeader
group by OrderDate
order by OrderDate
go

--use the intial query as a CTE (minus the order by)
with DailyAverages
as
(select format(OrderDate,'yyyy-MM-dd','en-us') as OrderDate, 
	avg(SubTotal) as DailyAvg
from Sales.SalesOrderHeader
group by OrderDate
)
--query the CTE using a windowed avg to get the three day rolling average
select OrderDate,
	avg(DailyAvg) over(order by OrderDate
		rows between 2 preceding and current row)
		as Rolling3DayAvg
from DailyAverages


/******* find IDs of product pairs sold in same order ********/

--check out the data
select * from Sales.SalesOrderDetail

--find IDs of product pairs sold together
select d1.ProductID as pid1,d2.ProductID as pid2
	,count(distinct d1.SalesOrderID) as orderCount 
from Sales.SalesOrderDetail as d1
	join --use self join to grab the second product
	Sales.SalesOrderDetail as d2
	on d1.SalesOrderID = d2.SalesOrderID and 
		d1.ProductID < d2.ProductID --using < rather than != avoids A-B / B-A duplication
group by d1.ProductID, d2.ProductID
order by orderCount desc

/****add product names to the previous query to make it more informative*****/

--can add top() to limit rows returned to top 10 etc.
select /**top (10)**/ d1.ProductID as pid1,p1.Name as product1Name
	,d2.ProductID as pid2, p2.Name as product2Name
	,count(distinct d1.SalesOrderID) as orderCount 
from Sales.SalesOrderDetail as d1
	join --use self join to grab the second product
	Sales.SalesOrderDetail as d2
	on d1.SalesOrderID = d2.SalesOrderID and 
		d1.ProductID < d2.ProductID --using < rather than != avoids A-B / B-A duplication
	left join Production.Product as p1
	on d1.ProductID = p1.ProductID
	left join Production.Product as p2
	on d2.ProductID = p2.ProductID
group by d1.ProductID,p1.Name, d2.ProductID, p2.Name
--could add a "having" to limit the rows returned by an orderCount threshold
--having count(distinct d1.SalesOrderID) > 1
order by orderCount desc


