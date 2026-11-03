CREATE DATABASE HotelReservations;
USE HotelReservations;

CREATE TABLE Room (
    room_no INT PRIMARY KEY,
    room_type VARCHAR(20),
    tariff INT,
    floor INT
);

CREATE TABLE Guest (
    guest_id INT PRIMARY KEY,
    name VARCHAR(50),
    city VARCHAR(30),
    loyalty VARCHAR(20)
);

CREATE TABLE Reservation (
    res_id INT PRIMARY KEY,
    guest_id INT,
    room_no INT,
    check_in DATE,
    check_out DATE,
    status VARCHAR(20),
    FOREIGN KEY (guest_id) REFERENCES Guest(guest_id),
    FOREIGN KEY (room_no) REFERENCES Room(room_no)
);

INSERT INTO Room VALUES
(101, 'Deluxe', 3500, 1),
(102, 'Deluxe', 3500, 1),
(201, 'Suite', 7000, 2),
(202, 'Standard', 2000, 2),
(301, 'Standard', 2000, 3);

INSERT INTO Guest VALUES
(1, 'Vivek Rao', 'Pune', 'Gold'),
(2, 'Meghana Iyer', 'Bengaluru', 'Silver'),
(3, 'Arjun Naik', 'Goa', 'Gold'),
(4, 'Ritu Sharma', 'Delhi', 'None');

INSERT INTO Reservation VALUES
(1, 1, 101, '2026-10-01', '2026-10-04', 'Completed'),
(2, 2, 201, '2026-10-03', '2026-10-05', 'Completed'),
(3, 1, 202, '2026-10-15', '2026-10-16', 'Completed'),
(4, 3, 201, '2026-10-20', '2026-10-23', 'Completed'),
(5, 3, 101, '2026-11-05', '2026-11-07', 'Booked'),
(6, 2, 301, '2026-11-10', '2026-11-12', 'Cancelled');


-- Q1
SELECT g.name AS guest_name, r.room_no, res.check_in
FROM Reservation res
INNER JOIN Guest g
ON res.guest_id = g.guest_id
INNER JOIN Room r
ON res.room_no = r.room_no;


-- Q2
SELECT r.room_no, r.room_type, res.res_id, res.guest_id, res.check_in, res.check_out, res.status
FROM Room r
LEFT JOIN Reservation res
ON r.room_no = res.room_no;


-- Q3
SELECT res_id, guest_id, room_no,
       DATEDIFF(check_out, check_in) AS nights
FROM Reservation;


-- Q4
SELECT r.room_type, COUNT(res.res_id) AS total_reservations
FROM Room r
LEFT JOIN Reservation res
ON r.room_no = res.room_no
GROUP BY r.room_type;


-- Q5
SELECT r.room_type, COUNT(res.res_id) AS total_reservations
FROM Room r
INNER JOIN Reservation res
ON r.room_no = res.room_no
GROUP BY r.room_type
HAVING COUNT(res.res_id) > 2;


-- Q6
SELECT
    MAX(tariff) AS highest_tariff,
    MIN(tariff) AS lowest_tariff,
    AVG(tariff) AS average_tariff
FROM Room;


-- Q7
SELECT *
FROM Guest
WHERE guest_id IN (
    SELECT guest_id
    FROM Reservation
    WHERE room_no IN (
        SELECT room_no
        FROM Room
        WHERE room_type = 'Suite'
    )
);


-- Q8
SELECT *
FROM Room
WHERE tariff > (
    SELECT AVG(tariff)
    FROM Room
);


-- Q9
CREATE VIEW upcoming_bookings AS
SELECT res_id, guest_id, room_no, check_in, check_out, status
FROM Reservation
WHERE status = 'Booked';

SELECT * FROM upcoming_bookings;


-- Q10
SELECT g.guest_id, g.name,
       COUNT(res.res_id) AS total_reservations
FROM Guest g
LEFT JOIN Reservation res
ON g.guest_id = res.guest_id
GROUP BY g.guest_id, g.name
ORDER BY g.name ASC;
