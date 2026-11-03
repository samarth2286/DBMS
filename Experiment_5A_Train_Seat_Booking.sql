CREATE DATABASE TrainSeatBooking;
USE TrainSeatBooking;

CREATE TABLE Train_Seat (
    seat_no VARCHAR(5) PRIMARY KEY,
    status VARCHAR(20)
) ENGINE=InnoDB;

INSERT INTO Train_Seat VALUES
('S1', 'Free'),
('S2', 'Free'),
('S3', 'Booked'),
('S4', 'Free');

SELECT * FROM Train_Seat;


-- Q1
-- Run the setup above once. Open two MySQL Workbench connections.
SET autocommit = 0;


-- Q2
SELECT @@transaction_isolation;


-- Q3
-- SESSION 1
START TRANSACTION;
UPDATE Train_Seat SET status = 'Booked' WHERE seat_no = 'S1';

-- SESSION 2
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
START TRANSACTION;
SELECT * FROM Train_Seat WHERE seat_no = 'S1';

-- SESSION 1
ROLLBACK;

-- SESSION 2
COMMIT;


-- Q4
-- SESSION 2
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM Train_Seat WHERE seat_no = 'S1';

-- SESSION 1
START TRANSACTION;
UPDATE Train_Seat SET status = 'Booked' WHERE seat_no = 'S1';
COMMIT;

-- SESSION 2
SELECT * FROM Train_Seat WHERE seat_no = 'S1';
COMMIT;


-- Q5
-- SESSION 2
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
START TRANSACTION;
SELECT * FROM Train_Seat WHERE seat_no = 'S2';

-- SESSION 1
START TRANSACTION;
UPDATE Train_Seat SET status = 'Booked' WHERE seat_no = 'S2';
COMMIT;

-- SESSION 2
SELECT * FROM Train_Seat WHERE seat_no = 'S2';
COMMIT;


-- Q6
-- SESSION 2
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
START TRANSACTION;
SELECT * FROM Train_Seat WHERE seat_no = 'S2';

-- SESSION 1
START TRANSACTION;
UPDATE Train_Seat SET status = 'Free' WHERE seat_no = 'S2';
COMMIT;

-- SESSION 2
SELECT * FROM Train_Seat WHERE seat_no = 'S2';
COMMIT;


-- Q7
-- SESSION 1
START TRANSACTION;
SELECT status FROM Train_Seat
WHERE seat_no = 'S4' FOR UPDATE;
UPDATE Train_Seat
SET status = 'Booked'
WHERE seat_no = 'S4';
COMMIT;

-- SESSION 2: execute while SESSION 1 holds the lock
START TRANSACTION;
SELECT status FROM Train_Seat
WHERE seat_no = 'S4' FOR UPDATE;
-- If status is Free, update it; otherwise do not book it.
UPDATE Train_Seat
SET status = 'Booked'
WHERE seat_no = 'S4' AND status = 'Free';
COMMIT;


-- Q8
-- SESSION 1
LOCK TABLES Train_Seat WRITE;
SELECT * FROM Train_Seat;

-- SESSION 2: this SELECT waits until SESSION 1 unlocks
SELECT * FROM Train_Seat;

-- SESSION 1
UNLOCK TABLES;


-- Q9
-- SESSION 1
SET SESSION innodb_lock_wait_timeout = 5;
START TRANSACTION;
UPDATE Train_Seat SET status = 'Booked' WHERE seat_no = 'S4';

-- SESSION 2: execute before SESSION 1 commits
SET SESSION innodb_lock_wait_timeout = 5;
START TRANSACTION;
UPDATE Train_Seat SET status = 'Free' WHERE seat_no = 'S4';
-- This may return ERROR 1205 after waiting.

-- SESSION 1
ROLLBACK;

-- SESSION 2
ROLLBACK;


-- Q10
-- Isolation level and anomalies:
-- READ UNCOMMITTED: dirty read possible.
-- READ COMMITTED: dirty read prevented; non-repeatable read possible.
-- REPEATABLE READ: dirty and non-repeatable reads prevented.
-- SERIALIZABLE: phantom reads prevented through stronger locking.
