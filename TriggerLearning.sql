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

select * from Employee;

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
