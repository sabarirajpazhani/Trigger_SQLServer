create database TriggerConcept;

--use database
use TriggerConcept;

-- Create Employee table
CREATE TABLE Employee
(
  Id int Primary Key,
  Name nvarchar(30),
  Salary int,
  Gender nvarchar(10),
  DepartmentId int
)
GO

-- Insert data into Employee table
INSERT INTO Employee VALUES (1,'Pranaya', 5000, 'Male', 3)
INSERT INTO Employee VALUES (2,'Priyanka', 5400, 'Female', 2)
INSERT INTO Employee VALUES (3,'Anurag', 6500, 'male', 1)
INSERT INTO Employee VALUES (4,'sambit', 4700, 'Male', 2)
INSERT INTO Employee VALUES (5,'Hina', 6600, 'Female', 3)

CREATE TABLE Department
(
  ID INT PRIMARY KEY,
  Name VARCHAR(50)
)
GO
-- Populate the Department Table with test data
INSERT INTO Department VALUES(1, 'IT')
INSERT INTO Department VALUES(2, 'HR')
INSERT INTO Department VALUES(3, 'Sales')


-- Create EmployeeAudit Table
CREATE TABLE EmployeeAudit
(
  ID INT IDENTITY(1,1) PRIMARY KEY,
  AuditData VARCHAR(MAX),
  AuditDate DATETIME
)


--creating the AFTER TRIGGER for INSERT
create trigger trInsertEmployee
on Employee
after insert
as
begin
	declare @ID int
	declare @Name varchar(100)
	declare @AuditData varchar(MAX)
	select @ID = ID ,@Name = Name from Inserted
	set @AuditData = 'New Employee Added with ID - '+ cast(@ID as varchar(10))+' and Name - '+@Name

	insert into EmployeeAudit(AuditData,AuditDate)
	values (@AuditData,Getdate())
end

insert into Employee values(6,'Sabari',8000, 'Male',2);

select * from Employee;
Select * from EmployeeAudit;

--AFTER TRIGGER for DELETE Event in SQL Server
create trigger tgDeleteEmployee
on Employee
after delete 
as
begin
	declare @ID int
	declare @Name varchar(max)
	declare @AuditData varchar(100)

	select @ID = Id, @Name = Name from DELETED
	set @AuditData = 'Employee Deleted with ID - '+cast(@ID as varchar(10))+' and Name - '+@Name

	insert into EmployeeAudit values(@AuditData,Getdate());
end

delete from Employee
where Id = 6;

select * from Employee;
Select * from EmployeeAudit;


--AFTER TRIGGER for UPDATE Event in SQL Server
create trigger tgUpdateEmployee
on Employee
after update
as begin
	declare @ID int
	declare @OldName varchar(200), @NewName varchar(200)
	declare @OldSalary int, @NewSalary int
	declare @OldGender varchar(40), @NewGender varchar(40)
	declare @OldDepartmentID int, @NewDepartmentID int

	declare @AuditData varchar(max)

	select * into #EmployeeTempTable from inserted

	while(Exists(select ID from #EmployeeTempTable))
	begin
		set @AuditData= ''

		select Top 1  
			@ID = ID,
			@NewName = Name,
			@NewSalary = Salary,
			@NewGender = Gender,
			@NewDepartmentID = DepartmentID
		from #EmployeeTempTable

		select 
			@OldName = Name,
			@OldSalary = Salary,
			@OldGender = Gender,
			@OldDepartmentID = DepartmentID
		from deleted where ID = @ID


		set @AuditData = 'Employee with id - '+cast(@ID as varchar(30)) + 'changed'

		if(@OldName <> @NewName)
		begin
		 set @AuditData = @AuditData + 'Name from '+cast(@OldName as varchar(30))+ ' to '+@NewName
		end

		if(@OldSalary <> @NewSalary)
		begin
			set @AuditData = @AuditData + 'Salary from ' + cast(@OldSalary as varchar(30)) + ' to ' + cast(@NewSalary as varchar(30))
		end

		if(@OldGender <> @NewGender)
		begin
			set @AuditData = @AuditData + 'Gender from '+cast(@OldGender as varchar(30))+ ' to '+@NewGender
		end

		if(@OldDepartmentID <> @NewDepartmentID)
		begin
			set @AuditData = @AuditData + 'Department ID from '+cast(@OldDepartmentID as varchar(30))+ ' to '+cast(@NewDepartmentID as varchar(30))
		end

		insert into EmployeeAudit values (@AuditData, Getdate())

		delete from #EmployeeTempTable where ID = @ID

	end
end


DROP TRIGGER tgUpdateEmployee;


update Employee
set Salary = 10000
where ID = 5;


select * from Employee;
Select * from EmployeeAudit;



----------------- instead of--------------------
create view vwEmployeeDetails
as
select emp.ID, emp.Name, emp.Salary, emp.Gender, dept.Name as Department
from Employee emp
inner join Department dept
on emp.DepartmentId = dept.ID;

select * from vwEmployeeDetails;

insert into vwEmployeeDetails values (6,'Raj',50000,'Male','IT');  -- its make error
--overcome this error we can create the instead of trigger
--INSTEAD OF INSERT Trigger in SQL Server
create trigger trVWEmployeeDetails
on vwEmployeeDetails
instead of insert
as 
begin
	declare @DepartmentID int
	select @DepartmentID = dept.ID from Department dept
	inner join inserted inst
	on inst.Department = dept.Name

	if(@DepartmentID = null)
	begin
		raiserror('Invalid Department name',16,1)
	end

	insert into Employee(ID,Name,Salary,Gender,DepartmentId)
	select ID,Name,Salary,Gender,@DepartmentID
	from inserted
end


--Instead Of Update Trigger in SQL Server
create trigger trVWInsteadOfUpdate
on vwEmployeeDetails
instead of update
as
begin
	--if EmployeeID is updated
	if(update(Id))
	begin
		raiserror('ID cannot be changed',16,1)
		return
	end

	--if Departmemnt is updated
	if(update(Department))
	begin
		declare @DepartmentID int
		select @DepartmentID = dept.ID
		from Department dept
		inner join inserted inst
		on dept.Name = inst.Department

		if(@DepartmentID is Null)
		begin
			raiserror('Ivalide Department Name',16,1)
			return
		end

		update Employee 
		set DepartmentId = @DepartmentID
		from inserted
		inner join Employee
		on Employee.Id = inserted.ID
	end

	--if gender is updated
	if(update(Gender))
	begin
		update Employee 
		set Gender = inst.Gender
		from inserted inst
		inner join Employee
		on Employee.Id = inst.ID
	end

	-- if salary is updated
	if(update(Salary))
	begin
		update Employee
		set Salary = inserted.Salary
		from inserted
		inner join Employee
		on Employee.Id = inserted.ID
	end
end

update vwEmployeeDetails
set Salary = 6000
where Id = 1;

select * from Employee;
Select * from EmployeeAudit;
select * from Department;

--Instead Of Delete Trigger in SQL Server
create trigger trvwInsteadOfDelete
on vwEmployeeDetails
instead of delete
as
begin
	delete from Employee
	from Employee emp
	inner join deleted del
	on emp.Id = del.Id
end

delete from vwEmployeeDetails
where ID =6;

select * from Employee;
select * from vwEmployeeDetails;
