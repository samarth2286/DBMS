CREATE DATABASE CollegeERPRoles;
USE CollegeERPRoles;

CREATE TABLE Student_Record (
    roll_no INT PRIMARY KEY,
    name VARCHAR(40),
    dept VARCHAR(20),
    cgpa DECIMAL(3,1),
    fee_due DECIMAL(10,2)
);

INSERT INTO Student_Record VALUES
(1, 'Aarti', 'AIML', 8.2, 25000),
(2, 'Bhushan', 'CSE', 7.5, 0),
(3, 'Chaitali', 'AIML', 9.0, 10000);


-- Q1
SELECT * FROM Student_Record;


-- Q2
CREATE ROLE IF NOT EXISTS 'erp_admin';
CREATE ROLE IF NOT EXISTS 'faculty';
CREATE ROLE IF NOT EXISTS 'student_role';


-- Q3
GRANT ALL PRIVILEGES
ON CollegeERPRoles.Student_Record
TO 'erp_admin';

GRANT SELECT, UPDATE (cgpa)
ON CollegeERPRoles.Student_Record
TO 'faculty';

GRANT SELECT (roll_no, name, cgpa)
ON CollegeERPRoles.Student_Record
TO 'student_role';


-- Q4
CREATE USER IF NOT EXISTS 'admin1'@'localhost'
IDENTIFIED BY 'Admin1@2026';

CREATE USER IF NOT EXISTS 'fac1'@'localhost'
IDENTIFIED BY 'Faculty@2026';

CREATE USER IF NOT EXISTS 'stud1'@'localhost'
IDENTIFIED BY 'Student@2026';

GRANT 'erp_admin' TO 'admin1'@'localhost';
GRANT 'faculty' TO 'fac1'@'localhost';
GRANT 'student_role' TO 'stud1'@'localhost';

SET DEFAULT ROLE 'erp_admin' TO 'admin1'@'localhost';
SET DEFAULT ROLE 'faculty' TO 'fac1'@'localhost';
SET DEFAULT ROLE 'student_role' TO 'stud1'@'localhost';


-- Q5
-- Connect as fac1:
UPDATE CollegeERPRoles.Student_Record
SET cgpa = 8.5
WHERE roll_no = 1;


-- Q6
-- Connect as fac1; this should fail:
UPDATE CollegeERPRoles.Student_Record
SET fee_due = 0
WHERE roll_no = 1;


-- Q7
-- Connect as stud1; this should fail:
SELECT fee_due
FROM CollegeERPRoles.Student_Record;


-- Q8
SHOW GRANTS FOR 'admin1'@'localhost';
SHOW GRANTS FOR 'fac1'@'localhost';
SHOW GRANTS FOR 'stud1'@'localhost';


-- Q9
REVOKE UPDATE (cgpa)
ON CollegeERPRoles.Student_Record
FROM 'faculty';

-- Connect as fac1; this should now fail:
UPDATE CollegeERPRoles.Student_Record
SET cgpa = 9.0
WHERE roll_no = 1;


-- Q10
ALTER USER 'stud1'@'localhost' ACCOUNT LOCK;
