CREATE DATABASE CourseRegistrationDB;
USE CourseRegistrationDB;

CREATE TABLE Course_Registration_Original (
    RegNo INT,
    StudName VARCHAR(30),
    CourseCode VARCHAR(10),
    CourseName VARCHAR(30),
    Instructor VARCHAR(30),
    InstrRoom VARCHAR(10),
    Credits INT,
    PRIMARY KEY (RegNo, CourseCode)
);

INSERT INTO Course_Registration_Original VALUES
(21, 'Gauri',  'CS301', 'DBMS', 'Prof. Shah', 'A-101', 4),
(21, 'Gauri',  'CS302', 'OS',   'Prof. Nair', 'A-205', 3),
(22, 'Harsh',  'CS301', 'DBMS', 'Prof. Shah', 'A-101', 4),
(23, 'Isha',   'CS303', 'CN',   'Prof. Bose', 'B-110', 3);

SELECT * FROM Course_Registration_Original;


-- Q1
SELECT RegNo, CourseCode
FROM Course_Registration_Original;


-- Q2


-- Q3


-- Q4


-- Q5
CREATE TABLE Student (
    RegNo INT PRIMARY KEY,
    StudName VARCHAR(30)
);

CREATE TABLE Instructor (
    Instructor VARCHAR(30) PRIMARY KEY,
    InstrRoom VARCHAR(10)
);

CREATE TABLE Course (
    CourseCode VARCHAR(10) PRIMARY KEY,
    CourseName VARCHAR(30),
    Instructor VARCHAR(30),
    Credits INT,
    FOREIGN KEY (Instructor) REFERENCES Instructor(Instructor)
);

CREATE TABLE Registration (
    RegNo INT,
    CourseCode VARCHAR(10),
    PRIMARY KEY (RegNo, CourseCode),
    FOREIGN KEY (RegNo) REFERENCES Student(RegNo),
    FOREIGN KEY (CourseCode) REFERENCES Course(CourseCode)
);


-- Q6


-- Q7


-- Q8
INSERT INTO Student VALUES
(21, 'Gauri'),
(22, 'Harsh'),
(23, 'Isha');

INSERT INTO Instructor VALUES
('Prof. Shah', 'A-101'),
('Prof. Nair', 'A-205'),
('Prof. Bose', 'B-110');

INSERT INTO Course VALUES
('CS301', 'DBMS', 'Prof. Shah', 4),
('CS302', 'OS', 'Prof. Nair', 3),
('CS303', 'CN', 'Prof. Bose', 3);

INSERT INTO Registration VALUES
(21, 'CS301'),
(21, 'CS302'),
(22, 'CS301'),
(23, 'CS303');


-- Q9
SELECT
    s.RegNo,
    s.StudName,
    c.CourseCode,
    c.CourseName,
    i.Instructor,
    i.InstrRoom,
    c.Credits
FROM Student s
INNER JOIN Registration r
ON s.RegNo = r.RegNo
INNER JOIN Course c
ON r.CourseCode = c.CourseCode
INNER JOIN Instructor i
ON c.Instructor = i.Instructor
WHERE i.Instructor = 'Prof. Shah';


-- Q10
UPDATE Instructor
SET InstrRoom = 'A-110'
WHERE Instructor = 'Prof. Shah';

SELECT * FROM Instructor;
