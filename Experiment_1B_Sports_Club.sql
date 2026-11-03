CREATE DATABASE SportsClub;
USE SportsClub;

CREATE TABLE Member (
    member_id INT PRIMARY KEY,
    name VARCHAR(50),
    gender CHAR(1),
    dob DATE,
    phone VARCHAR(15) UNIQUE
);

CREATE TABLE Sport (
    sport_id VARCHAR(5) PRIMARY KEY,
    sport_name VARCHAR(30),
    coach VARCHAR(50),
    monthly_fee DECIMAL(10,2),
    max_members INT,
    CHECK (monthly_fee > 0)
);

CREATE TABLE Registration (
    member_id INT,
    sport_id VARCHAR(5),
    reg_date DATE,
    status VARCHAR(20),
    PRIMARY KEY (member_id, sport_id),
    FOREIGN KEY (member_id) REFERENCES Member(member_id),
    FOREIGN KEY (sport_id) REFERENCES Sport(sport_id)
);

INSERT INTO Member VALUES
(101, 'Kunal Shinde', 'M', '2004-03-12', '9822100001'),
(102, 'Pooja Desai', 'F', '2005-07-25', '9822100002'),
(103, 'Rahul Jagtap', 'M', '2003-11-02', '9822100003'),
(104, 'Tanvi Chavan', 'F', '2006-01-18', '9822100004');

INSERT INTO Sport VALUES
('S1', 'Badminton', 'Mr. Sawant', 800, 20),
('S2', 'Swimming', 'Ms. Kulkarni', 1500, 15),
('S3', 'Table Tennis', 'Mr. Gaikwad', 600, 12);

INSERT INTO Registration VALUES
(101, 'S1', '2026-07-01', 'Active'),
(101, 'S2', '2026-08-10', 'Active'),
(102, 'S2', '2026-07-15', 'Active'),
(103, 'S3', '2026-06-20', 'Inactive'),
(104, 'S1', '2026-09-05', 'Active');

SELECT * FROM Member;
SELECT * FROM Sport;
SELECT * FROM Registration;


-- Q1
-- ER MODEL: Member (1) -> (M) Registration (M) <- (1) Sport


-- Q2
-- Table creation and integrity constraints are defined above.


-- Q3
-- Insert statements and display queries are given above.


-- Q4
INSERT INTO Member VALUES
(105, 'Duplicate Test', 'M', '2004-05-10', '9822100001');


-- Q5
ALTER TABLE Member
ADD email VARCHAR(100);


-- Q6
ALTER TABLE Registration
ALTER COLUMN status SET DEFAULT 'Active';


-- Q7
SELECT m.name
FROM Member m
INNER JOIN Registration r
ON m.member_id = r.member_id
INNER JOIN Sport s
ON r.sport_id = s.sport_id
WHERE s.sport_name = 'Badminton';


-- Q8
UPDATE Sport
SET monthly_fee = monthly_fee * 0.90
WHERE sport_name = 'Table Tennis';


-- Q9
DELETE FROM Registration
WHERE member_id = 104;

DELETE FROM Member
WHERE member_id = 104;

SELECT * FROM Member;


-- Q10
CREATE USER IF NOT EXISTS 'coach1'@'localhost'
IDENTIFIED BY 'Coach@123';

GRANT SELECT, UPDATE ON SportsClub.Registration
TO 'coach1'@'localhost';

REVOKE UPDATE ON SportsClub.Registration
FROM 'coach1'@'localhost';

SHOW GRANTS FOR 'coach1'@'localhost';
