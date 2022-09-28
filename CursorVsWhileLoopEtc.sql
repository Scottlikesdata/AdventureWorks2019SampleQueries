/******* Row-based options:
		Cursor version - lots of sources say to avoid these if possible ************/

declare @employeeId int
declare csr cursor for
select BusinessEntityID
from HumanResources.Employee
where BusinessEntityID between 15 and 225

open csr
fetch next from csr into @employeeId
while @@FETCH_STATUS = 0
begin
	select e.BusinessEntityID, p.FirstName, p.LastName, e.JobTitle,
		h.Rate, h.PayFrequency, h.RateChangeDate, h.ModifiedDate
	from HumanResources.Employee as e
	left join Person.Person as p
	on e.BusinessEntityID = p.BusinessEntityID
	left join HumanResources.EmployeePayHistory as h
	on e.BusinessEntityID = h.BusinessEntityID
	where e.BusinessEntityID = @employeeId
	fetch next from csr into @employeeId
end
close csr
deallocate csr
go

/****** While loop version ************/
declare @BusinessEntityID int = 15
while @BusinessEntityID <= 225
begin
select e.BusinessEntityID, p.FirstName, p.LastName, e.JobTitle,
		h.Rate, h.PayFrequency, h.RateChangeDate, h.ModifiedDate
	from HumanResources.Employee as e
	left join Person.Person as p
	on e.BusinessEntityID = p.BusinessEntityID
	left join HumanResources.EmployeePayHistory as h
	on e.BusinessEntityID = h.BusinessEntityID
	where e.BusinessEntityID = @BusinessEntityID
	set @BusinessEntityID += 1
end
go

/**************** set-based alternatives: much faster *************/

--chooses all records in one set:
select e.BusinessEntityID, p.FirstName, p.LastName, e.JobTitle,
		h.Rate, h.PayFrequency, h.RateChangeDate, h.ModifiedDate
	from HumanResources.Employee as e
	left join Person.Person as p
	on e.BusinessEntityID = p.BusinessEntityID
	left join HumanResources.EmployeePayHistory as h
	on e.BusinessEntityID = h.BusinessEntityID
where e.BusinessEntityID between 15 and 225

/**** uses a CTE to return only those employees from the query above that
		have had pay rate changes ****************************************************/
with payRates as
(select e.BusinessEntityID, p.FirstName, p.LastName, e.JobTitle,
		h.Rate, h.PayFrequency, h.RateChangeDate, h.ModifiedDate,
		count(e.BusinessEntityID) over (partition by e.BusinessEntityID order by e.BusinessEntityID) as counter
	from HumanResources.Employee as e
	left join Person.Person as p
	on e.BusinessEntityID = p.BusinessEntityID
	left join HumanResources.EmployeePayHistory as h
	on e.BusinessEntityID = h.BusinessEntityID
where e.BusinessEntityID between 15 and 225)
select BusinessEntityID, FirstName, LastName, JobTitle,
		Rate, PayFrequency, RateChangeDate, ModifiedDate
from payRates
where counter > 1
go

/********** find the current pay for each employee with ID between 15 and 225 ********/
declare @BusinessEntityID int = 15
drop table if exists #currentpay
select * into #currentpay
from
(select e.BusinessEntityID, p.FirstName, p.LastName, e.JobTitle,
		h.Rate, h.PayFrequency, h.RateChangeDate, h.ModifiedDate
	from HumanResources.Employee as e
	left join Person.Person as p
	on e.BusinessEntityID = p.BusinessEntityID
	left join HumanResources.EmployeePayHistory as h
	on e.BusinessEntityID = h.BusinessEntityID
where 1 = 2) as template
while @BusinessEntityID <= 225
begin
insert into #currentpay
select top 1 e.BusinessEntityID, p.FirstName, p.LastName, e.JobTitle,
		h.Rate, h.PayFrequency, h.RateChangeDate, h.ModifiedDate
	from HumanResources.Employee as e
	left join Person.Person as p
	on e.BusinessEntityID = p.BusinessEntityID
	left join HumanResources.EmployeePayHistory as h
	on e.BusinessEntityID = h.BusinessEntityID
where e.BusinessEntityID = @BusinessEntityID
order by h.RateChangeDate desc
set @BusinessEntityID += 1
end
select * from #currentpay