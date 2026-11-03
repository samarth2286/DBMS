# Save this code as Experiment_9C_Hospital_MySQL_Python.py
# Install: pip install mysql-connector-python
 
import mysql.connector
from mysql.connector import Error
from tabulate import tabulate
 
connection = None
cursor = None
 
try:
    connection = mysql.connector.connect(
        host="localhost",
        user="root",
        password="YOUR_PASSWORD"
    )
    cursor = connection.cursor()
    cursor.execute("SELECT VERSION()")
    print("MySQL Server Version:", cursor.fetchone()[0])
 
    cursor.execute("CREATE DATABASE IF NOT EXISTS hospitalDB")
    cursor.execute("USE hospitalDB")
 
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS Doctor (
            doctor_id INT PRIMARY KEY,
            name VARCHAR(100),
            specialization VARCHAR(100),
            fee DECIMAL(10,2),
            phone VARCHAR(15)
        )
    """)
 
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS Patient (
            patient_id INT PRIMARY KEY,
            name VARCHAR(100),
            age INT,
            gender CHAR(1),
            blood_group VARCHAR(5),
            phone VARCHAR(15),
            city VARCHAR(50)
        )
    """)
 
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS Appointment (
            appt_id INT PRIMARY KEY,
            patient_id INT,
            doctor_id INT,
            appt_date DATETIME,
            status VARCHAR(20),
            FOREIGN KEY (patient_id) REFERENCES Patient(patient_id),
            FOREIGN KEY (doctor_id) REFERENCES Doctor(doctor_id)
        )
    """)
 
    cursor.execute("""
        CREATE TABLE IF NOT EXISTS Bill (
            bill_id INT PRIMARY KEY,
            appt_id INT,
            patient_id INT,
            amount DECIMAL(10,2) CHECK (amount > 0),
            status VARCHAR(20),
            FOREIGN KEY (appt_id) REFERENCES Appointment(appt_id),
            FOREIGN KEY (patient_id) REFERENCES Patient(patient_id)
        )
    """)
 
    cursor.executemany(
        "INSERT INTO Doctor VALUES (%s,%s,%s,%s,%s)",
        [
            (1, "Dr. Prakash Rao", "Neurology", 900, "9890400001"),
            (2, "Dr. Meenal Gokhale", "Dermatology", 500, "9890400002"),
            (3, "Dr. Ajit Sawant", "General Medicine", 300, "9890400003")
        ]
    )
 
    cursor.executemany(
        "INSERT INTO Patient VALUES (%s,%s,%s,%s,%s,%s,%s)",
        [
            (101, "Ravi Bhosale", 45, "M", "O+", "9765400001", "Satara"),
            (102, "Kalpana More", 38, "F", "A+", "9765400002", "Karad"),
            (103, "Tushar Jadhav", 22, "M", "B-", "9765400003", "Satara")
        ]
    )
    connection.commit()
 
    cursor.executemany(
        "INSERT INTO Appointment VALUES (%s,%s,%s,%s,%s)",
        [
            (501, 101, 1, "2026-11-02 10:00:00", "Completed"),
            (502, 102, 2, "2026-11-02 11:00:00", "Completed"),
            (503, 103, 3, "2026-11-03 09:30:00", "Scheduled")
        ]
    )
 
    cursor.executemany(
        "INSERT INTO Bill VALUES (%s,%s,%s,%s,%s)",
        [
            (9001, 501, 101, 1400, "Paid"),
            (9002, 502, 102, 500, "Pending")
        ]
    )
    connection.commit()
 
    # 5. Display appointments with patient and doctor names
    cursor.execute("""
        SELECT a.appt_id, p.name, d.name, a.appt_date, a.status
        FROM Appointment a
        JOIN Patient p ON a.patient_id = p.patient_id
        JOIN Doctor d ON a.doctor_id = d.doctor_id
    """)
    print(tabulate(cursor.fetchall(),
                   headers=["Appointment", "Patient", "Doctor", "Date", "Status"],
                   tablefmt="grid"))
 
    # 6. Read IDs and date, then insert parameterized appointment
    patient_id = int(input("Enter patient ID: "))
    doctor_id = int(input("Enter doctor ID: "))
    appt_date = input("Enter appointment date (YYYY-MM-DD HH:MM:SS): ")
    cursor.execute(
        "INSERT INTO Appointment VALUES (%s,%s,%s,%s,%s)",
        (504, patient_id, doctor_id, appt_date, "Scheduled")
    )
    connection.commit()
 
    # 7. Pending bills with patient name and phone
    cursor.execute("""
        SELECT b.bill_id, p.name, p.phone, b.amount, b.status
        FROM Bill b
        JOIN Patient p ON b.patient_id = p.patient_id
        WHERE b.status = %s
    """, ("Pending",))
    print(tabulate(cursor.fetchall(),
                   headers=["Bill ID", "Patient", "Phone", "Amount", "Status"],
                   tablefmt="grid"))
 
    # 8. Mark bill 9002 as Paid
    cursor.execute(
        "UPDATE Bill SET status = %s WHERE bill_id = %s",
        ("Paid", 9002)
    )
    connection.commit()
    print("Rows updated:", cursor.rowcount)
 
    # 9. Transaction with deliberate error to demonstrate rollback
    try:
        connection.start_transaction()
        cursor.execute(
            "INSERT INTO Bill VALUES (%s,%s,%s,%s,%s)",
            (9010, 503, 103, 300, "Pending")
        )
        cursor.execute("INSERT INTO TableThatDoesNotExist VALUES (1)")
        connection.commit()
    except Error as e:
        connection.rollback()
        print("Transaction rolled back:", e)
 
except Error as e:
    print("MySQL Error:", e)
 
finally:
    if cursor is not None:
        cursor.close()
    if connection is not None and connection.is_connected():
        connection.close()
        print("MySQL connection closed")
