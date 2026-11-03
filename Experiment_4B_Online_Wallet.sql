CREATE DATABASE OnlineWallet;
USE OnlineWallet;

CREATE TABLE Wallet (
    wallet_id INT PRIMARY KEY,
    owner VARCHAR(30),
    balance DECIMAL(10,2)
);

CREATE TABLE Wallet_Txn (
    txn_id INT AUTO_INCREMENT PRIMARY KEY,
    wallet_id INT,
    txn_type VARCHAR(10),
    amount DECIMAL(10,2),
    txn_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (wallet_id) REFERENCES Wallet(wallet_id)
);

INSERT INTO Wallet VALUES
(1, 'Priya', 5000),
(2, 'Sameer', 1200),
(3, 'Tejal', 300);


-- Q1
SELECT * FROM Wallet;
SELECT * FROM Wallet_Txn;


-- Q2
DELIMITER //

CREATE TRIGGER before_wallet_update
BEFORE UPDATE ON Wallet
FOR EACH ROW
BEGIN
    IF NEW.balance < 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Insufficient balance';
    END IF;
END //

DELIMITER ;


-- Q3
DELIMITER //

CREATE TRIGGER after_wallet_update
AFTER UPDATE ON Wallet
FOR EACH ROW
BEGIN
    IF NEW.balance < OLD.balance THEN
        INSERT INTO Wallet_Txn (wallet_id, txn_type, amount)
        VALUES (NEW.wallet_id, 'Debit', OLD.balance - NEW.balance);
    ELSEIF NEW.balance > OLD.balance THEN
        INSERT INTO Wallet_Txn (wallet_id, txn_type, amount)
        VALUES (NEW.wallet_id, 'Credit', NEW.balance - OLD.balance);
    END IF;
END //

DELIMITER ;


-- Q4
DELIMITER //

CREATE PROCEDURE add_money(IN wid INT, IN amt DECIMAL(10,2))
BEGIN
    UPDATE Wallet
    SET balance = balance + amt
    WHERE wallet_id = wid;
END //

DELIMITER ;


-- Q5
DELIMITER //

CREATE PROCEDURE pay(IN from_wid INT, IN to_wid INT, IN amt DECIMAL(10,2))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    UPDATE Wallet
    SET balance = balance - amt
    WHERE wallet_id = from_wid;

    UPDATE Wallet
    SET balance = balance + amt
    WHERE wallet_id = to_wid;

    COMMIT;
END //

DELIMITER ;


-- Q6
CALL pay(1, 2, 1000);

SELECT * FROM Wallet;
SELECT * FROM Wallet_Txn;


-- Q7
CALL pay(3, 1, 500);

SELECT * FROM Wallet;
SELECT * FROM Wallet_Txn;


-- Q8
DELIMITER //

CREATE FUNCTION get_balance(wid INT)
RETURNS DECIMAL(10,2)
READS SQL DATA
BEGIN
    DECLARE current_balance DECIMAL(10,2);

    SELECT balance INTO current_balance
    FROM Wallet
    WHERE wallet_id = wid;

    RETURN current_balance;
END //

DELIMITER ;

SELECT get_balance(1) AS balance;


-- Q9
START TRANSACTION;

UPDATE Wallet
SET balance = balance + 100
WHERE wallet_id = 1;

SELECT * FROM Wallet WHERE wallet_id = 1;

COMMIT;


-- Q10
DROP TRIGGER after_wallet_update;

UPDATE Wallet
SET balance = balance - 100
WHERE wallet_id = 1;

SELECT * FROM Wallet;
SELECT * FROM Wallet_Txn;
