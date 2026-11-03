CREATE DATABASE BankStaffPrivileges;
USE BankStaffPrivileges;

CREATE TABLE Account (
    acc_no INT PRIMARY KEY,
    holder VARCHAR(40),
    acc_type VARCHAR(20),
    balance DECIMAL(12,2)
);

INSERT INTO Account VALUES
(9001, 'Rohit', 'Savings', 40000),
(9002, 'Swati', 'Current', 150000),
(9003, 'Vinay', 'Savings', 7000);


-- Q1
SELECT * FROM Account;


-- Q2
CREATE USER IF NOT EXISTS 'teller'@'localhost'
IDENTIFIED BY 'Teller@2026'
PASSWORD EXPIRE INTERVAL 30 DAY;


-- Q3
GRANT SELECT, UPDATE (balance)
ON BankStaffPrivileges.Account
TO 'teller'@'localhost';


-- Q4
CREATE OR REPLACE VIEW savings_accounts AS
SELECT acc_no, holder, acc_type, balance
FROM Account
WHERE acc_type = 'Savings';

CREATE USER IF NOT EXISTS 'auditor'@'localhost'
IDENTIFIED BY 'Auditor@2026';

GRANT SELECT ON BankStaffPrivileges.savings_accounts
TO 'auditor'@'localhost';


-- Q5
-- Connect as auditor:
SELECT * FROM BankStaffPrivileges.savings_accounts;
-- This should fail for auditor:
SELECT * FROM BankStaffPrivileges.Account;


-- Q6
DELIMITER //

CREATE PROCEDURE deposit(IN acc INT, IN amt DECIMAL(12,2))
SQL SECURITY DEFINER
BEGIN
    IF amt <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Deposit amount must be positive';
    END IF;

    UPDATE Account
    SET balance = balance + amt
    WHERE acc_no = acc;
END //

DELIMITER ;

GRANT EXECUTE ON PROCEDURE BankStaffPrivileges.deposit
TO 'teller'@'localhost';


-- Q7
-- Connect as teller:
CALL BankStaffPrivileges.deposit(9001, 5000);
-- This should fail for teller:
DELETE FROM BankStaffPrivileges.Account WHERE acc_no = 9001;


-- Q8
CREATE USER IF NOT EXISTS 'bank_mgr'@'localhost'
IDENTIFIED BY 'Manager@2026';

CREATE USER IF NOT EXISTS 'branch_viewer'@'localhost'
IDENTIFIED BY 'Viewer@2026';

GRANT SELECT ON BankStaffPrivileges.Account
TO 'bank_mgr'@'localhost'
WITH GRANT OPTION;

-- Connect as bank_mgr:
GRANT SELECT ON BankStaffPrivileges.Account
TO 'branch_viewer'@'localhost';


-- Q9
REVOKE EXECUTE ON PROCEDURE BankStaffPrivileges.deposit
FROM 'teller'@'localhost';

-- Connect as teller; this should now fail:
CALL BankStaffPrivileges.deposit(9001, 1000);


-- Q10
ALTER USER 'teller'@'localhost'
IDENTIFIED BY 'TellerNew@2026';

DROP USER IF EXISTS 'auditor'@'localhost';
