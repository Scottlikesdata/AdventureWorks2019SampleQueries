--Progression of queries on tables from the Product schema

--1. Pulls product info from Product, ProductSubcategory and ProductCategory tables
use AdventureWorks2019;
select P.ProductID, P.Name as ProductName, P.ProductNumber, P.ListPrice,
--assign 999 to null subcat values and Parts to null cat and subcat names
case when P.ProductSubcategoryID is null then 999 else P.ProductSubcategoryID end as [ProductSubcategoryID],
case when S.Name is null then 'Parts' else S.Name end as SubCatName, 
case when C.Name is null then 'Parts' else C.Name end as CatName
from Production.Product as P
--use left joins to keep all rows from Product table
left join Production.ProductSubcategory as S
on P.ProductSubcategoryID = S.ProductSubcategoryID
left join Production.ProductCategory as C
on S.ProductCategoryID = C.ProductCategoryID
order by CatName, SubCatName, ProductName
go

--****************************************************************************************
/* 2. using a CTE (with clause) with one select statement afterwards, which is the limit,
to pull product info from four production tables.*/
go
use AdventureWorks2019;
with ProductInventoryInfo as
	(select P.Name as ProductName, P.ProductNumber, P.ListPrice,
--assign 999 to null subcat values and Parts to null cat and subcat names
	case when P.ProductSubcategoryID is null then 999 else P.ProductSubcategoryID end as [ProductSubcategoryID],
	case when S.Name is null then 'Parts' else S.Name end as SubCatName, 
	case when C.Name is null then 'Parts' else C.Name end as CatName,
	I.*
	from Production.Product as P
--use left joins to keep all rows from Product table
	left join Production.ProductSubcategory as S
	on P.ProductSubcategoryID = S.ProductSubcategoryID
	left join Production.ProductCategory as C
	on S.ProductCategoryID = C.ProductCategoryID
	left join Production.ProductInventory as I
	on P.ProductID = I.ProductID)
--select columns from CTE
select ProductName, ProductNumber, ListPrice, ProductSubcategoryID, SubCatName, CatName,ProductID, LocationID,
	Shelf, Bin, Quantity, ModifiedDate
from ProductInventoryInfo

/* 3. The same query as above, but using a temp table instead of a CTE 
in order to have multiple select statements that reference the results
of the temp table*/
go
use AdventureWorks2019;
select P.Name as ProductName, P.ProductNumber, P.ListPrice,
	case when P.ProductSubcategoryID is null then 999 else P.ProductSubcategoryID end as [ProductSubcategoryID],
	case when S.Name is null then 'Parts' else S.Name end as SubCatName, 
	case when C.Name is null then 'Parts' else C.Name end as CatName, 
	I.*
into #tmpProductInventoryInfo
	from Production.Product as P
	left join Production.ProductSubcategory as S
		on P.ProductSubcategoryID = S.ProductSubcategoryID
	left join Production.ProductCategory as C
		on S.ProductCategoryID = C.ProductCategoryID
	left join Production.ProductInventory as I
		on P.ProductID = I.ProductID
select ProductName, ProductNumber, ListPrice, ProductSubcategoryID, SubCatName, CatName,ProductID, LocationID,
		Shelf, Bin, Quantity, ModifiedDate
	from #tmpProductInventoryInfo
select ProductName, Shelf, Bin, Quantity, 
		sum(Quantity) over(partition by ProductName order by ProductName) as TotalOnHand
	from #tmpProductInventoryInfo
select ProductName, sum(Quantity) as ProductTotal
	from #tmpProductInventoryInfo
	group by ProductName
drop table #tmpProductInventoryInfo
go

--4. Create a view from query number one above
use AdventureWorks2019;
go
create view Production.vProductAndCategoryInfo
as
select P.ProductID, P.Name as ProductName, P.ProductNumber, P.ListPrice,
--assign 999 to null subcat values and Parts to null cat and subcat names
case when P.ProductSubcategoryID is null then 999 else P.ProductSubcategoryID end as [ProductSubcategoryID],
case when S.Name is null then 'Parts' else S.Name end as SubCatName, 
case when C.Name is null then 'Parts' else C.Name end as CatName
from Production.Product as P
--use left joins to keep all rows from Product table
left join Production.ProductSubcategory as S
on P.ProductSubcategoryID = S.ProductSubcategoryID
left join Production.ProductCategory as C
on S.ProductCategoryID = C.ProductCategoryID
--can't use "order by" in views so it has been removed
;
go
