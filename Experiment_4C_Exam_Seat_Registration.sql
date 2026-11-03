CREATE DATABASE ExamSeatRegistration;
USE ExamSeatRegistration;

CREATE TABLE Exam (
    exam_id VARCHAR(5) PRIMARY KEY,
    subject VARCHAR(30),
    seats_left INT
);

CREATE TABLE Registration (
    reg_id INT AUTO_INCREMENT PRIMARY KEY,
    exam_id VARCHAR(5),
    student VARCHAR(40),
    status VARCHAR(10) DEFAULT 'Active',
    FOREIGN KEY (exam_id) REFERENCES Exam(exam_id)
);

INSERT INTO Exam VALUES
('EX1', 'DBMS', 3),
('EX2', 'Python', 40);


-- Q1
SELECT * FROM Exam;
SELECT * FROM Registration;


-- Q2
DELIMITER //

CREATE TRIGGER after_registration_insert
AFTER INSERT ON Registration
FOR EACH ROW
BEGIN
    UPDATE Exam
    SET seats_left = seats_left - 1
    WHERE exam_id = NEW.exam_id;
END //

DELIMITER ;


-- Q3
DELIMITER //

CREATE TRIGGER before_registration_insert
BEFORE INSERT ON Registration
FOR EACH ROW
BEGIN
    DECLARE available_seats INT;

    SELECT seats_left INTO available_seats
    FROM Exam
    WHERE exam_id = NEW.exam_id;

    IF available_seats <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'No seats available';
    END IF;
END //

DELIMITER ;


-- Q4
INSERT INTO Registration (exam_id, student) VALUES ('EX1', 'Aarav');
INSERT INTO Registration (exam_id, student) VALUES ('EX1', 'Diya');
INSERT INTO Registration (exam_id, student) VALUES ('EX1', 'Rohan');

INSERT INTO Registration (exam_id, student) VALUES ('EX1', 'Fourth Student');


-- Q5
DELIMITER //

CREATE TRIGGER after_registration_update
AFTER UPDATE ON Registration
FOR EACH ROW
BEGIN
    IF OLD.status <> 'Withdrawn' AND NEW.status = 'Withdrawn' THEN
        UPDATE Exam
        SET seats_left = seats_left + 1
        WHERE exam_id = NEW.exam_id;
    END IF;
END //

DELIMITER ;


-- Q6
UPDATE Registration
SET status = 'Withdrawn'
WHERE reg_id = 1;

SELECT * FROM Exam;
SELECT * FROM Registration;


-- Q7
DELIMITER //

CREATE PROCEDURE register_student(IN eid VARCHAR(5), IN name VARCHAR(40))
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;

    START TRANSACTION;

    INSERT INTO Registration (exam_id, student)
    VALUES (eid, name);

    COMMIT;
END //

DELIMITER ;


-- Q8
DELIMITER //

CREATE FUNCTION seats_filled(eid VARCHAR(5))
RETURNS INT
READS SQL DATA
BEGIN
    DECLARE filled INT;

    SELECT COUNT(*) INTO filled
    FROM Registration
    WHERE exam_id = eid AND status = 'Active';

    RETURN filled;
END //

DELIMITER ;

SELECT seats_filled('EX1') AS active_registrations;


-- Q9
START TRANSACTION;

INSERT INTO Registration (exam_id, student)
VALUES ('EX2', 'Student One');

SAVEPOINT second_student;

INSERT INTO Registration (exam_id, student)
VALUES ('EX2', 'Student Two');

ROLLBACK TO second_student;
COMMIT;

SELECT * FROM Registration;


-- Q10
SHOW TRIGGERS;
