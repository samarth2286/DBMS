CREATE DATABASE BusReservation;
USE BusReservation;

CREATE TABLE Route (
    route_id VARCHAR(5) PRIMARY KEY,
    source VARCHAR(30),
    destination VARCHAR(30),
    distance_km INT,
    fare DECIMAL(10,2),
    CHECK (fare > 0)
);

CREATE TABLE Bus (
    bus_no VARCHAR(20) PRIMARY KEY,
    route_id VARCHAR(5),
    bus_type VARCHAR(30),
    capacity INT,
    FOREIGN KEY (route_id) REFERENCES Route(route_id)
);

CREATE TABLE Booking (
    booking_id INT PRIMARY KEY,
    bus_no VARCHAR(20),
    passenger VARCHAR(50) NOT NULL,
    mobile VARCHAR(15),
    journey_date DATE,
    seats INT,
    FOREIGN KEY (bus_no) REFERENCES Bus(bus_no)
);

INSERT INTO Route VALUES
('R1', 'Sangli', 'Pune', 230, 450),
('R2', 'Kolhapur', 'Mumbai', 380, 700),
('R3', 'Sangli', 'Goa', 260, 550);

INSERT INTO Bus VALUES
('MH10-AB-1001', 'R1', 'AC Sleeper', 36),
('MH09-CD-2002', 'R2', 'Non-AC Seater', 45),
('MH10-EF-3003', 'R3', 'AC Seater', 40);

INSERT INTO Booking VALUES
(1, 'MH10-AB-1001', 'Rohan Patil', '9876500001', '2026-11-20', 2),
(2, 'MH09-CD-2002', 'Snehal Kadam', '9876500002', '2026-11-21', 1),
(3, 'MH10-AB-1001', 'Akash More', '9876500003', '2026-11-20', 3);

SELECT * FROM Route;
SELECT * FROM Bus;
SELECT * FROM Booking;


-- Q1
-- ER MODEL: Route (1) -> (M) Bus (1) -> (M) Booking


-- Q2
-- Table creation and integrity constraints are defined above.


-- Q3
-- Insert statements and display queries are given above.


-- Q4
INSERT INTO Booking VALUES
(4, 'MH12-ZZ-9999', 'Test Passenger', '9876500004', '2026-11-22', 1);


-- Q5
ALTER TABLE Booking
ADD email VARCHAR(100);


-- Q6
UPDATE Route
SET fare = fare * 1.10
WHERE source = 'Sangli';


-- Q7
SELECT b.passenger, b.bus_no, r.source, r.destination
FROM Booking b
INNER JOIN Bus bu
ON b.bus_no = bu.bus_no
INNER JOIN Route r
ON bu.route_id = r.route_id;


-- Q8
DELETE FROM Booking
WHERE booking_id = 2;


-- Q9
CREATE USER IF NOT EXISTS 'conductor'@'localhost'
IDENTIFIED BY 'Conductor@123';

GRANT SELECT ON BusReservation.Booking
TO 'conductor'@'localhost';

REVOKE SELECT ON BusReservation.Booking
FROM 'conductor'@'localhost';


-- Q10
CREATE TABLE Booking_Copy LIKE Booking;

INSERT INTO Booking_Copy
SELECT * FROM Booking;

TRUNCATE TABLE Booking_Copy;

DROP TABLE Booking_Copy;
