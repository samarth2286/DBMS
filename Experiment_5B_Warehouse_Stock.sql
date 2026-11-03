CREATE DATABASE WarehouseStock;
USE WarehouseStock;

CREATE TABLE Stock (
    item_id INT PRIMARY KEY,
    item_name VARCHAR(40),
    qty INT
) ENGINE=InnoDB;

INSERT INTO Stock VALUES
(1, 'Cement bags', 500),
(2, 'Steel rods', 300);

SELECT * FROM Stock;


-- Q1
-- Run setup once in one session. Open two MySQL Workbench connections.
-- Execute this in BOTH sessions:
SET autocommit = 0;


-- Q2
-- SESSION 1
START TRANSACTION;
SELECT qty FROM Stock WHERE item_id = 1;

-- SESSION 2
START TRANSACTION;
SELECT qty FROM Stock WHERE item_id = 1;

-- SESSION 1
UPDATE Stock SET qty = 400 WHERE item_id = 1;
COMMIT;

-- SESSION 2: stale value 500 was read earlier
UPDATE Stock SET qty = 450 WHERE item_id = 1;
COMMIT;

SELECT * FROM Stock;


-- Q3
-- Schedule:
-- S1: READ qty=500
-- S2: READ qty=500
-- S1: WRITE qty=400, COMMIT
-- S2: WRITE qty=450, COMMIT
-- Final qty=450; S1's update is lost.


-- Q4
UPDATE Stock SET qty = 500 WHERE item_id = 1;
COMMIT;

-- SESSION 1
START TRANSACTION;
SELECT qty FROM Stock WHERE item_id = 1 FOR UPDATE;
UPDATE Stock SET qty = qty - 100 WHERE item_id = 1;
COMMIT;

-- SESSION 2: run while SESSION 1 holds its FOR UPDATE lock
START TRANSACTION;
SELECT qty FROM Stock WHERE item_id = 1 FOR UPDATE;
UPDATE Stock SET qty = qty - 50 WHERE item_id = 1;
COMMIT;

SELECT * FROM Stock;


-- Q5
UPDATE Stock SET qty = 500 WHERE item_id = 1;
COMMIT;

-- SESSION 1
START TRANSACTION;
UPDATE Stock SET qty = qty - 100 WHERE item_id = 1;
COMMIT;

-- SESSION 2: execute after SESSION 1 commits
START TRANSACTION;
UPDATE Stock SET qty = qty - 50 WHERE item_id = 1;
COMMIT;

SELECT * FROM Stock;


-- Q6
-- Reset before starting the deadlock demonstration.
UPDATE Stock SET qty = 500 WHERE item_id = 1;
UPDATE Stock SET qty = 300 WHERE item_id = 2;
COMMIT;

-- SESSION 1
START TRANSACTION;
UPDATE Stock SET qty = qty - 10 WHERE item_id = 1;

-- SESSION 2
START TRANSACTION;
UPDATE Stock SET qty = qty - 20 WHERE item_id = 2;

-- SESSION 1: this waits for SESSION 2
UPDATE Stock SET qty = qty - 10 WHERE item_id = 2;

-- SESSION 2: run while SESSION 1 is waiting; this creates a deadlock
UPDATE Stock SET qty = qty - 20 WHERE item_id = 1;
-- InnoDB detects the deadlock and rolls back one transaction.


-- Q7
-- Check which transaction survived and inspect the quantities:
SELECT * FROM Stock;
-- Commit the surviving transaction if it is still active:
COMMIT;


-- Q8
-- Wait-for graph:
-- T1 holds item 1 and waits for item 2.
-- T2 holds item 2 and waits for item 1.
-- T1 -> T2 -> T1 (cycle = deadlock).


-- Q9
UPDATE Stock SET qty = 500 WHERE item_id = 1;
UPDATE Stock SET qty = 300 WHERE item_id = 2;
COMMIT;

-- SESSION 1: update items in ascending item_id order
START TRANSACTION;
UPDATE Stock SET qty = qty - 10 WHERE item_id = 1;
UPDATE Stock SET qty = qty - 10 WHERE item_id = 2;
COMMIT;

-- SESSION 2: use the same order; run concurrently with SESSION 1
START TRANSACTION;
UPDATE Stock SET qty = qty - 20 WHERE item_id = 1;
UPDATE Stock SET qty = qty - 20 WHERE item_id = 2;
COMMIT;

SELECT * FROM Stock;


-- Q10
-- Two-phase locking:
-- Growing phase: transaction acquires locks and does not release any.
-- Shrinking phase: transaction releases locks and acquires no new locks.
-- Holding locks until commit/rollback prevents conflicting updates
-- from using stale values; a consistent item order reduces deadlocks.
