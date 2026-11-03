CREATE DATABASE CarRental;
USE CarRental;

CREATE TABLE Customer (
    cust_id VARCHAR(5) PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(30),
    licence_no VARCHAR(20) UNIQUE
);

CREATE TABLE Car (
    reg_no VARCHAR(20) PRIMARY KEY,
    model VARCHAR(30),
    fuel VARCHAR(20),
    rate_per_day DECIMAL(10,2),
    status VARCHAR(20),
    CHECK (rate_per_day > 0)
);

CREATE TABLE Rental (
    rental_id INT PRIMARY KEY,
    cust_id VARCHAR(5),
    reg_no VARCHAR(20),
    start_date DATE,
    end_date DATE,
    amount DECIMAL(10,2),
    FOREIGN KEY (cust_id) REFERENCES Customer(cust_id),
    FOREIGN KEY (reg_no) REFERENCES Car(reg_no)
);

INSERT INTO Customer VALUES
('C01', 'Amit Joshi', 'Sangli', 'DL-1001'),
('C02', 'Neha Pawar', 'Pune', 'DL-1002'),
('C03', 'Sagar Mane', 'Satara', 'DL-1003');

INSERT INTO Car VALUES
('MH10-K-1111', 'Swift', 'Petrol', 1800, 'Available'),
('MH10-K-2222', 'Nexon EV', 'Electric', 2800, 'Rented'),
('MH09-L-3333', 'Innova', 'Diesel', 3500, 'Available'),
('MH12-M-4444', 'City', 'Petrol', 2500, 'Maintenance');

INSERT INTO Rental VALUES
(1, 'C01', 'MH10-K-2222', '2026-10-25', '2026-10-28', 8400),
(2, 'C02', 'MH09-L-3333', '2026-10-10', '2026-10-12', 7000),
(3, 'C01', 'MH10-K-1111', '2026-09-01', '2026-09-05', 7200);

SELECT * FROM Customer;
SELECT * FROM Car;
SELECT * FROM Rental;


-- Q1
-- ER MODEL: Customer (1) -> (M) Rental (M) <- (1) Car


-- Q2
-- Table creation and integrity constraints are defined above.


-- Q3
-- Insert statements and display queries are given above.


-- Q4
INSERT INTO Rental VALUES
(4, 'C09', 'MH10-K-1111', '2026-11-01', '2026-11-03', 3600);


-- Q5
ALTER TABLE Rental
ADD km_driven INT DEFAULT 0;


-- Q6
UPDATE Car
SET status = 'Available'
WHERE reg_no = 'MH12-M-4444';


-- Q7
SELECT c.name AS customer_name, ca.model, r.amount
FROM Rental r
INNER JOIN Customer c
ON r.cust_id = c.cust_id
INNER JOIN Car ca
ON r.reg_no = ca.reg_no;


-- Q8
SELECT *
FROM Car
WHERE status = 'Available';


-- Q9
CREATE USER IF NOT EXISTS 'fleet_manager'@'localhost'
IDENTIFIED BY 'Fleet@123';

GRANT SELECT, INSERT ON CarRental.Car
TO 'fleet_manager'@'localhost';

REVOKE INSERT ON CarRental.Car
FROM 'fleet_manager'@'localhost';


-- Q10
RENAME TABLE Rental TO Car_Rental;

SHOW TABLES;
