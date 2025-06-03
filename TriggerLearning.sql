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