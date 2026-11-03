CREATE DATABASE ElectricityBilling;
USE ElectricityBilling;

CREATE TABLE Consumer (
    consumer_id INT PRIMARY KEY,
    name VARCHAR(40),
    category VARCHAR(20)
);

CREATE TABLE Bill (
    bill_id INT AUTO_INCREMENT PRIMARY KEY,
    consumer_id INT,
    units INT,
    amount DECIMAL(10,2),
    bill_month VARCHAR(10),
    FOREIGN KEY (consumer_id) REFERENCES Consumer(consumer_id)
);

CREATE TABLE Bill_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    consumer_id INT,
    amount DECIMAL(10,2),
    log_time DATETIME DEFAULT CURRENT_TIMESTAMP
);

INSERT INTO Consumer VALUES
(501, 'Ramesh', 'Residential'),
(502, 'Om Traders', 'Commercial'),
(503, 'Sunita', 'Residential');


-- Q1
SELECT * FROM Consumer;
SELECT * FROM Bill;
SELECT * FROM Bill_Log;


-- Q2
DELIMITER //

CREATE TRIGGER before_bill_insert_amount
BEFORE INSERT ON Bill
FOR EACH ROW
BEGIN
    DECLARE consumer_category VARCHAR(20);

    SELECT category INTO consumer_category
    FROM Consumer
    WHERE consumer_id = NEW.consumer_id;

    IF consumer_category = 'Residential' THEN
        SET NEW.amount = NEW.units * 6;
    ELSEIF consumer_category = 'Commercial' THEN
        SET NEW.amount = NEW.units * 9;
    END IF;
END //

DELIMITER ;


-- Q3
DELIMITER //

CREATE TRIGGER before_bill_insert_units
BEFORE INSERT ON Bill
FOR EACH ROW
BEGIN
    IF NEW.units < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Units cannot be negative';
    END IF;
END //

DELIMITER ;


-- Q4
DELIMITER //

CREATE TRIGGER after_bill_insert_log
AFTER INSERT ON Bill
FOR EACH ROW
BEGIN
    INSERT INTO Bill_Log (consumer_id, amount)
    VALUES (NEW.consumer_id, NEW.amount);
END //

DELIMITER ;


-- Q5
INSERT INTO Bill (consumer_id, units, amount, bill_month)
VALUES
(501, 100, 0, '2026-10'),
(502, 200, 0, '2026-10'),
(503, 150, 0, '2026-10');

SELECT * FROM Bill;
SELECT * FROM Bill_Log;


-- Q6
DELIMITER //

CREATE PROCEDURE add_bill(IN cid INT, IN units INT, IN billmonth VARCHAR(10))
BEGIN
    INSERT INTO Bill (consumer_id, units, amount, bill_month)
    VALUES (cid, units, 0, billmonth);
END //

DELIMITER ;


-- Q7
DELIMITER //

CREATE FUNCTION total_paid(cid INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE total DECIMAL(10,2);

    SELECT COALESCE(SUM(amount), 0) INTO total
    FROM Bill
    WHERE consumer_id = cid;

    RETURN total;
END //

DELIMITER ;

SELECT total_paid(501) AS total_bill_amount;


-- Q8
DELIMITER //

CREATE PROCEDURE category_total(IN cat VARCHAR(20), OUT total DECIMAL(10,2))
BEGIN
    SELECT COALESCE(SUM(b.amount), 0) INTO total
    FROM Bill b
    INNER JOIN Consumer c
    ON b.consumer_id = c.consumer_id
    WHERE c.category = cat;
END //

DELIMITER ;

CALL category_total('Residential', @total);
SELECT @total AS residential_total;


-- Q9
START TRANSACTION;

INSERT INTO Bill (consumer_id, units, amount, bill_month)
VALUES (501, 50, 0, '2026-11');

INSERT INTO Bill (consumer_id, units, amount, bill_month)
VALUES (502, 60, 0, '2026-11');

ROLLBACK;

SELECT * FROM Bill;
SELECT * FROM Bill_Log;


-- Q10
START TRANSACTION;

INSERT INTO Bill (consumer_id, units, amount, bill_month)
VALUES (501, 40, 0, '2026-12');

SAVEPOINT second_bill;

INSERT INTO Bill (consumer_id, units, amount, bill_month)
VALUES (502, 70, 0, '2026-12');

ROLLBACK TO second_bill;
COMMIT;

SELECT * FROM Bill;
SELECT * FROM Bill_Log;
