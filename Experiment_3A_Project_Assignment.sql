CREATE DATABASE ProjectAssignmentDB;
USE ProjectAssignmentDB;

CREATE TABLE Project_Assignment_1NF (
    EmpID VARCHAR(5),
    EmpName VARCHAR(30),
    Dept VARCHAR(20),
    DeptHead VARCHAR(30),
    ProjID VARCHAR(5),
    ProjName VARCHAR(30),
    Hours INT,
    PRIMARY KEY (EmpID, ProjID)
);

INSERT INTO Project_Assignment_1NF VALUES
('E1', 'Ajay', 'IT', 'Mr. Rao', 'P1', 'Billing', 10),
('E1', 'Ajay', 'IT', 'Mr. Rao', 'P2', 'Portal', 15),
('E2', 'Bhavna', 'HR', 'Ms. Iyer', 'P2', 'Portal', 20),
('E3', 'Chetan', 'IT', 'Mr. Rao', 'P1', 'Billing', 12),
('E3', 'Chetan', 'IT', 'Mr. Rao', 'P3', 'Analytics', 8);

SELECT * FROM Project_Assignment_1NF;


-- Q1
SELECT * FROM Project_Assignment_1NF;


-- Q2
SELECT * FROM Project_Assignment_1NF;


-- Q3
SELECT EmpID, ProjID
FROM Project_Assignment_1NF;


-- Q4


-- Q5


-- Q6


-- Q7
CREATE TABLE Department (
    Dept VARCHAR(20) PRIMARY KEY,
    DeptHead VARCHAR(30)
);

CREATE TABLE Employee (
    EmpID VARCHAR(5) PRIMARY KEY,
    EmpName VARCHAR(30),
    Dept VARCHAR(20),
    FOREIGN KEY (Dept) REFERENCES Department(Dept)
);

CREATE TABLE Project (
    ProjID VARCHAR(5) PRIMARY KEY,
    ProjName VARCHAR(30)
);

CREATE TABLE Assignment (
    EmpID VARCHAR(5),
    ProjID VARCHAR(5),
    Hours INT,
    PRIMARY KEY (EmpID, ProjID),
    FOREIGN KEY (EmpID) REFERENCES Employee(EmpID),
    FOREIGN KEY (ProjID) REFERENCES Project(ProjID)
);


-- Q8


-- Q9
INSERT INTO Department VALUES
('IT', 'Mr. Rao'),
('HR', 'Ms. Iyer');

INSERT INTO Employee VALUES
('E1', 'Ajay', 'IT'),
('E2', 'Bhavna', 'HR'),
('E3', 'Chetan', 'IT');

INSERT INTO Project VALUES
('P1', 'Billing'),
('P2', 'Portal'),
('P3', 'Analytics');

INSERT INTO Assignment VALUES
('E1', 'P1', 10),
('E1', 'P2', 15),
('E2', 'P2', 20),
('E3', 'P1', 12),
('E3', 'P3', 8);


-- Q9
SELECT
    e.EmpID,
    e.EmpName,
    e.Dept,
    d.DeptHead,
    p.ProjID,
    p.ProjName,
    a.Hours
FROM Employee e
INNER JOIN Department d
ON e.Dept = d.Dept
INNER JOIN Assignment a
ON e.EmpID = a.EmpID
INNER JOIN Project p
ON a.ProjID = p.ProjID;


-- Q10
SELECT
    e.EmpID,
    e.EmpName,
    SUM(a.Hours) AS TotalHours
FROM Employee e
INNER JOIN Assignment a
ON e.EmpID = a.EmpID
GROUP BY e.EmpID, e.EmpName;
