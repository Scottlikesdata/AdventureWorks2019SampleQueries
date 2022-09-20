use AdventureWorks2019

/****** I used the following select statements to get a limited amount of rows
		to work with for a practice merge and double check what
		the max SalesOrderID was ************/
select * from Sales.SalesOrderHeader
where OrderDate = '20140630'

select max(SalesOrderID) from Sales.SalesOrderHeader
where OrderDate = '20140630'
go

/***** This sets up the target table for the merge. I chose to use temp tables 
		so as to not affect the demo tables in the AdventureWorks2019 database. *******/
drop table if exists #temptarget
select *
into #temptarget
from Sales.SalesOrderHeader
where OrderDate > '20140601' and OrderDate < '20140701'
select * from #temptarget

/*********	This sets up the source table for the merge. The first select statement 
			chooses even numbered rows from 20140630 and adds 1 to the SubTotal and 
			TotalDue to have data to change for the "When Matched" part. The second
			select after the union creates another 40 entries for 20140701 to have data
			for the "When not matched by target" part. I didn't create anything for
			"When not matched by source" **********/
drop table if exists #updates
select SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate
	,Status, OnlineOrderFlag, SalesOrderNumber, PurchaseOrderNumber
	,AccountNumber, CustomerID, SalesPersonID, TerritoryID
	,BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode
	,CurrencyRateID, SubTotal+1 as Subtotal, TaxAmt, Freight, TotalDue+1 as TotalDue
	,Comment, rowguid, ModifiedDate
into #updates
from Sales.SalesOrderHeader
where OrderDate = '20140630' and /*only even numbered rows*/ SalesOrderID %2 = 0 
union
select 75123 + ROW_NUMBER() over (order by SalesOrderID) as SalesOrderID
	,RevisionNumber, dateadd(day,1,OrderDate) as OrderDate
	,dateadd(day,1,DueDate) as DueDate
	,dateadd(day,1,ShipDate) as ShipDate
	,Status, OnlineOrderFlag
	--make SalesOrderNumber match new SalesOrderID
	,concat('SO',75123 + ROW_NUMBER() over (order by SalesOrderID)) as SalesOrderNumber
	,PurchaseOrderNumber, AccountNumber, CustomerID, SalesPersonID, TerritoryID
	,BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode
	,CurrencyRateID, SubTotal, TaxAmt, Freight, TotalDue, Comment
	,NEWID() as rowguid
	,dateadd(day,1,ModifiedDate) as ModifiedDate
from Sales.SalesOrderHeader
where OrderDate = '20140630';
select * from #updates
go



--begin tran
/******turn identity_insert on so that I can insert the SalesOrderIDs I created and not have
		them be auto-generated. *****/
set identity_insert tempdb.dbo.#temptarget on
merge into #temptarget as t
using #updates as src
on t.SalesOrderID = src.SalesOrderID
--I used the "when matched and" to keep this from update matching rows that have already benn
--updated if it is run a second time
when matched and t.Subtotal <> src.Subtotal then
	update set	t.SubTotal = src.SubTotal,
				TotalDue = src.TotalDue
when not matched by target then
	insert (SalesOrderID, RevisionNumber, OrderDate, DueDate, ShipDate
	,Status, OnlineOrderFlag, SalesOrderNumber, PurchaseOrderNumber
	,AccountNumber, CustomerID, SalesPersonID, TerritoryID
	,BillToAddressID, ShipToAddressID, ShipMethodID, CreditCardID, CreditCardApprovalCode
	,CurrencyRateID, SubTotal, TaxAmt, Freight, TotalDue
	,Comment, rowguid, ModifiedDate)
	values (src.SalesOrderID, src.RevisionNumber, src.OrderDate, src.DueDate, src.ShipDate
	,src.Status, src.OnlineOrderFlag, src.SalesOrderNumber, src.PurchaseOrderNumber
	,src.AccountNumber, src.CustomerID, src.SalesPersonID, src.TerritoryID
	,src.BillToAddressID, src.ShipToAddressID, src.ShipMethodID, src.CreditCardID, src.CreditCardApprovalCode
	,src.CurrencyRateID, src.SubTotal, src.TaxAmt, src.Freight, src.TotalDue
	,src.Comment, src.rowguid, src.ModifiedDate)
output deleted.SalesOrderID as DeletedbyUpdate, inserted.SalesOrderID as AddedbyUpdateOrInsert
;
select * from #temptarget order by SalesOrderID
--rollback tran
				


