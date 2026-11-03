CREATE DATABASE LabSlotDB;
USE LabSlotDB;

CREATE TABLE Lab_Slot_Original (
    Student VARCHAR(30),
    Course VARCHAR(30),
    LabInstructor VARCHAR(30),
    PRIMARY KEY (Student, Course)
);

INSERT INTO Lab_Slot_Original VALUES
('Kavya', 'Python Lab', 'Mr. Joshi'),
('Kavya', 'DBMS Lab', 'Ms. Rane'),
('Lalit', 'Python Lab', 'Mr. Joshi'),
('Mansi', 'Python Lab', 'Mr. Patil'),
('Mansi', 'DBMS Lab', 'Ms. Rane');

SELECT * FROM Lab_Slot_Original;


-- Q1


-- Q2


-- Q3


-- Q4


-- Q5


-- Q6
CREATE TABLE Instructor_Course (
    LabInstructor VARCHAR(30) PRIMARY KEY,
    Course VARCHAR(30)
);

CREATE TABLE Student_Instructor (
    Student VARCHAR(30),
    LabInstructor VARCHAR(30),
    PRIMARY KEY (Student, LabInstructor),
    FOREIGN KEY (LabInstructor) REFERENCES Instructor_Course(LabInstructor)
);


-- Q7


-- Q8


-- Q9
INSERT INTO Instructor_Course VALUES
('Mr. Joshi', 'Python Lab'),
('Ms. Rane', 'DBMS Lab'),
('Mr. Patil', 'Python Lab');

INSERT INTO Student_Instructor VALUES
('Kavya', 'Mr. Joshi'),
('Kavya', 'Ms. Rane'),
('Lalit', 'Mr. Joshi'),
('Mansi', 'Mr. Patil'),
('Mansi', 'Ms. Rane');


-- Q10
SELECT
    si.Student,
    ic.Course,
    si.LabInstructor
FROM Student_Instructor si
INNER JOIN Instructor_Course ic
ON si.LabInstructor = ic.LabInstructor
ORDER BY si.Student, ic.Course;
