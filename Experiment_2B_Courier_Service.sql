CREATE DATABASE CourierService;
USE CourierService;

CREATE TABLE Branch (
    branch_id VARCHAR(5) PRIMARY KEY,
    city VARCHAR(30),
    zone VARCHAR(20)
);

CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    name VARCHAR(30),
    branch_id VARCHAR(5),
    supervisor_id INT,
    role VARCHAR(20),
    salary INT,
    FOREIGN KEY (branch_id) REFERENCES Branch(branch_id),
    FOREIGN KEY (supervisor_id) REFERENCES Employee(emp_id)
);

CREATE TABLE Shipment (
    ship_id INT PRIMARY KEY,
    from_branch VARCHAR(5),
    to_branch VARCHAR(5),
    agent_id INT,
    weight_kg DECIMAL(5,2),
    charge INT,
    ship_date DATE,
    status VARCHAR(20),
    FOREIGN KEY (from_branch) REFERENCES Branch(branch_id),
    FOREIGN KEY (to_branch) REFERENCES Branch(branch_id),
    FOREIGN KEY (agent_id) REFERENCES Employee(emp_id)
);

INSERT INTO Branch VALUES
('B1', 'Sangli', 'West'),
('B2', 'Pune', 'West'),
('B3', 'Nagpur', 'Central'),
('B4', 'Nashik', 'North');

INSERT INTO Employee VALUES
(1, 'Manoj', 'B1', NULL, 'Manager', 45000),
(2, 'Kiran', 'B1', 1, 'Agent', 22000),
(3, 'Asha', 'B2', 1, 'Manager', 42000),
(4, 'Deepak', 'B2', 3, 'Agent', 21000),
(5, 'Farah', 'B2', 3, 'Agent', 23000),
(6, 'Nilesh', 'B3', 1, 'Agent', 20000);

INSERT INTO Shipment VALUES
(1001, 'B1', 'B2', 2, 2.5, 180, '2026-09-02', 'Delivered'),
(1002, 'B2', 'B3', 4, 10, 650, '2026-09-10', 'Delivered'),
(1003, 'B1', 'B3', 2, 1.2, 220, '2026-09-25', 'Returned'),
(1004, 'B2', 'B1', 5, 6, 400, '2026-10-04', 'Delivered'),
(1005, 'B3', 'B2', 6, 3, 260, '2026-10-11', 'In Transit'),
(1006, 'B2', 'B1', 4, 15, 900, '2026-10-18', 'Delivered');

SELECT * FROM Branch;
SELECT * FROM Employee;
SELECT * FROM Shipment;


-- Q1
SELECT s.ship_id, s.from_branch, s.to_branch,
       e.name AS agent_name, s.charge, s.status
FROM Shipment s
INNER JOIN Employee e
ON s.agent_id = e.emp_id;


-- Q2
SELECT e.name AS employee_name,
       s.name AS supervisor_name
FROM Employee e
LEFT JOIN Employee s
ON e.supervisor_id = s.emp_id;


-- Q3
SELECT b.branch_id, b.city, e.name AS employee_name
FROM Branch b
LEFT JOIN Employee e
ON b.branch_id = e.branch_id;


-- Q4
SELECT status, SUM(charge) AS total_charge
FROM Shipment
GROUP BY status;


-- Q5
SELECT e.emp_id, e.name,
       COUNT(s.ship_id) AS total_shipments
FROM Employee e
INNER JOIN Shipment s
ON e.emp_id = s.agent_id
WHERE e.role = 'Agent'
GROUP BY e.emp_id, e.name
HAVING COUNT(s.ship_id) > 1;


-- Q6
SELECT *
FROM Shipment
WHERE charge = (
    SELECT MAX(charge)
    FROM Shipment
);


-- Q7
SELECT *
FROM Employee
WHERE salary > (
    SELECT AVG(salary)
    FROM Employee
);


-- Q8
SELECT *
FROM Shipment
WHERE from_branch = (
    SELECT branch_id
    FROM Branch
    WHERE city = 'Pune'
);


-- Q9
CREATE VIEW delivered_shipments AS
SELECT s.ship_id, e.name AS agent_name, s.charge
FROM Shipment s
INNER JOIN Employee e
ON s.agent_id = e.emp_id
WHERE s.status = 'Delivered';

SELECT * FROM delivered_shipments;


-- Q10
SELECT DATE_FORMAT(ship_date, '%Y-%m') AS month,
       SUM(charge) AS total_charge
FROM Shipment
GROUP BY DATE_FORMAT(ship_date, '%Y-%m')
ORDER BY month;
