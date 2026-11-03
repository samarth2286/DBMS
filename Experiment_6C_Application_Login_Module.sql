CREATE DATABASE AppLoginModule;
USE AppLoginModule;

CREATE TABLE App_User (
    user_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(30) UNIQUE NOT NULL,
    password_hash CHAR(64) NOT NULL,
    role VARCHAR(20),
    failed_attempts INT DEFAULT 0,
    is_locked TINYINT(1) DEFAULT 0
);

CREATE TABLE Login_Log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(30),
    login_time DATETIME DEFAULT CURRENT_TIMESTAMP,
    status VARCHAR(10)
);


-- Q1
SELECT * FROM App_User;
SELECT * FROM Login_Log;


-- Q2
INSERT INTO App_User (username, password_hash, role)
VALUES
('admin', SHA2('Admin@2026', 256), 'admin'),
('neha', SHA2('Neha@2026', 256), 'staff');

SELECT username, password_hash, role
FROM App_User;


-- Q3
DELIMITER //

CREATE PROCEDURE register_user(
    IN uname VARCHAR(30),
    IN pwd VARCHAR(100),
    IN user_role VARCHAR(20)
)
BEGIN
    IF CHAR_LENGTH(pwd) < 8 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Password must contain at least 8 characters';
    END IF;

    INSERT INTO App_User (username, password_hash, role)
    VALUES (uname, SHA2(pwd, 256), user_role);
END //

DELIMITER ;


-- Q4
-- Password length is checked inside register_user.


-- Q5
DELIMITER //

CREATE PROCEDURE login(
    IN uname VARCHAR(30),
    IN pwd VARCHAR(100),
    OUT msg VARCHAR(100)
)
BEGIN
    DECLARE stored_hash CHAR(64);
    DECLARE attempts INT DEFAULT 0;
    DECLARE locked_status TINYINT DEFAULT 0;

    SELECT password_hash, failed_attempts, is_locked
    INTO stored_hash, attempts, locked_status
    FROM App_User
    WHERE username = uname;

    IF stored_hash IS NULL THEN
        SET msg = 'Invalid username or password';
        INSERT INTO Login_Log (username, status)
        VALUES (uname, 'Failed');

    ELSEIF locked_status = 1 THEN
        SET msg = 'Account is Locked';
        INSERT INTO Login_Log (username, status)
        VALUES (uname, 'Locked');

    ELSEIF stored_hash = SHA2(pwd, 256) THEN
        UPDATE App_User
        SET failed_attempts = 0
        WHERE username = uname;

        SET msg = 'Login Successful';
        INSERT INTO Login_Log (username, status)
        VALUES (uname, 'Success');

    ELSE
        UPDATE App_User
        SET is_locked = IF(failed_attempts >= 2, 1, 0),
            failed_attempts = failed_attempts + 1
        WHERE username = uname;

        SELECT is_locked INTO locked_status
        FROM App_User
        WHERE username = uname;

        IF locked_status = 1 THEN
            SET msg = 'Account is Locked';
            INSERT INTO Login_Log (username, status)
            VALUES (uname, 'Locked');
        ELSE
            SET msg = 'Invalid password';
            INSERT INTO Login_Log (username, status)
            VALUES (uname, 'Failed');
        END IF;
    END IF;
END //

DELIMITER ;


-- Q6
-- Failed attempts and account locking are handled in login.


-- Q7
-- Login attempts are recorded in Login_Log by login.


-- Q8
SET @message = '';
CALL login('neha', 'Neha@2026', @message);
SELECT @message AS response;

SET @message = '';
CALL login('neha', 'wrong1', @message);
SELECT @message AS response;

SET @message = '';
CALL login('neha', 'wrong2', @message);
SELECT @message AS response;

SET @message = '';
CALL login('neha', 'wrong3', @message);
SELECT @message AS response;

SET @message = '';
CALL login('neha', 'Neha@2026', @message);
SELECT @message AS response;

SELECT * FROM App_User;
SELECT * FROM Login_Log;


-- Q9
DELIMITER //

CREATE PROCEDURE change_password(
    IN uname VARCHAR(30),
    IN old_pwd VARCHAR(100),
    IN new_pwd VARCHAR(100)
)
BEGIN
    DECLARE current_hash CHAR(64);

    IF CHAR_LENGTH(new_pwd) < 8 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'New password must contain at least 8 characters';
    END IF;

    SELECT password_hash INTO current_hash
    FROM App_User
    WHERE username = uname;

    IF current_hash = SHA2(old_pwd, 256) THEN
        UPDATE App_User
        SET password_hash = SHA2(new_pwd, 256),
            failed_attempts = 0,
            is_locked = 0
        WHERE username = uname;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Old password is incorrect';
    END IF;
END //

DELIMITER ;


-- Q10
SELECT
    u.username,
    l.login_time,
    l.status,
    u.failed_attempts
FROM App_User u
LEFT JOIN Login_Log l
ON u.username = l.username
ORDER BY u.username, l.login_time;
