use attendanceDB
 
db.students.insertMany([
  { _id: "S01", name: "Aditi Patil", gender: "F", dept: "AIML", semester: 3, contact: { phone: "9822200001", city: "Sangli" } },
  { _id: "S02", name: "Rohit Kamble", gender: "M", dept: "AIML", semester: 3, contact: { phone: "9822200002", city: "Miraj" } },
  { _id: "S03", name: "Sneha Mali", gender: "F", dept: "CSE", semester: 5, contact: { phone: "9822200003", city: "Kolhapur" } },
  { _id: "S04", name: "Yash Shinde", gender: "M", dept: "CSE", semester: 5, contact: { phone: "9822200004", city: "Sangli" } },
  { _id: "S05", name: "Pranav Joshi", gender: "M", dept: "AIML", semester: 3, contact: { phone: "9822200005", city: "Satara" } }
])
 
db.courses.insertMany([
  { _id: "C11", name: "DBMS", credits: 4, faculty: "Dr. Patil", semester: 3 },
  { _id: "C12", name: "DAA", credits: 4, faculty: "Dr. Kale", semester: 3 },
  { _id: "C21", name: "Computer Networks", credits: 3, faculty: "Dr. Joshi", semester: 5 }
])
 
db.attendance.insertMany([
  { student_id: "S01", course_id: "C11", total: 40, attended: 37 },
  { student_id: "S01", course_id: "C12", total: 38, attended: 30 },
  { student_id: "S02", course_id: "C11", total: 40, attended: 26 },
  { student_id: "S02", course_id: "C12", total: 38, attended: 33 },
  { student_id: "S05", course_id: "C11", total: 40, attended: 31 },
  { student_id: "S05", course_id: "C12", total: 38, attended: 24 },
  { student_id: "S03", course_id: "C21", total: 36, attended: 30 },
  { student_id: "S04", course_id: "C21", total: 36, attended: 25 }
])
 
// 2. Display all AIML students
db.students.find({ dept: "AIML" })
 
// 3. Sangli students: name and phone
db.students.find(
  { "contact.city": "Sangli" },
  { _id: 0, name: 1, "contact.phone": 1 }
)
 
// 4. Attendance percentage for every record
db.attendance.aggregate([
  { $set: { percentage: { $multiply: [{ $divide: ["$attended", "$total"] }, 100] } } }
])
 
// 5. Defaulters with student and course names
db.attendance.aggregate([
  { $set: { percentage: { $multiply: [{ $divide: ["$attended", "$total"] }, 100] } } },
  { $match: { percentage: { $lt: 75 } } },
  { $lookup: { from: "students", localField: "student_id", foreignField: "_id", as: "student" } },
  { $lookup: { from: "courses", localField: "course_id", foreignField: "_id", as: "course" } },
  { $unwind: "$student" },
  { $unwind: "$course" },
  { $project: { _id: 0, student: "$student.name", course: "$course.name", percentage: 1 } }
])
 
// 6. Course-wise average attendance percentage
db.attendance.aggregate([
  { $set: { percentage: { $multiply: [{ $divide: ["$attended", "$total"] }, 100] } } },
  { $group: { _id: "$course_id", averageAttendance: { $avg: "$percentage" } } },
  { $lookup: { from: "courses", localField: "_id", foreignField: "_id", as: "course" } },
  { $unwind: "$course" },
  { $project: { _id: 0, course: "$course.name", averageAttendance: 1 } }
])
 
// 7. Add two C12 lectures; S02 attended both
db.attendance.updateMany(
  { course_id: "C12" },
  { $inc: { total: 2 } }
)
 
db.attendance.updateOne(
  { student_id: "S02", course_id: "C12" },
  { $inc: { attended: 2 } }
)
 
// 8. Add student S06 and attendance records
db.students.insertOne({
  _id: "S06",
  name: "Neha Shah",
  gender: "F",
  dept: "AIML",
  semester: 3,
  contact: { phone: "9822200006", city: "Pune" }
})
 
db.attendance.insertMany([
  { student_id: "S06", course_id: "C11", total: 40, attended: 36 },
  { student_id: "S06", course_id: "C12", total: 40, attended: 35 }
])
 
// 9. Count defaulters in each department
db.attendance.aggregate([
  { $set: { percentage: { $multiply: [{ $divide: ["$attended", "$total"] }, 100] } } },
  { $match: { percentage: { $lt: 75 } } },
  { $lookup: { from: "students", localField: "student_id", foreignField: "_id", as: "student" } },
  { $unwind: "$student" },
  { $group: { _id: "$student.dept", defaulterCount: { $addToSet: "$student._id" } } },
  { $project: { _id: 0, department: "$_id", defaulterCount: { $size: "$defaulterCount" } } }
])
 
// 10. Delete S04 attendance records
db.attendance.deleteMany({ student_id: "S04" })
