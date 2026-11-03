use resultDB
 
db.students.insertMany([
  { _id: "R01", name: "Kiran Desai", gender: "M", dept: "AIML", semester: 5 },
  { _id: "R02", name: "Lata Pawar", gender: "F", dept: "AIML", semester: 5 },
  { _id: "R03", name: "Manish Gore", gender: "M", dept: "AIML", semester: 5 },
  { _id: "R04", name: "Nisha Kulkarni", gender: "F", dept: "AIML", semester: 5 }
])
 
db.courses.insertMany([
  { _id: "M51", name: "Machine Learning", credits: 4, faculty: "Dr. Kale" },
  { _id: "M52", name: "Deep Learning", credits: 4, faculty: "Dr. Rao" },
  { _id: "M53", name: "Data Mining", credits: 3, faculty: "Dr. Shah" }
])
 
db.exams.insertMany([
  { student_id: "R01", course_id: "M51", ise: 28, ese: 40, total: 68 },
  { student_id: "R01", course_id: "M52", ise: 15, ese: 18, total: 33 },
  { student_id: "R02", course_id: "M51", ise: 37, ese: 55, total: 92 },
  { student_id: "R02", course_id: "M52", ise: 33, ese: 47, total: 80 },
  { student_id: "R02", course_id: "M53", ise: 0, ese: 0, total: 0 },
  { student_id: "R03", course_id: "M51", ise: 22, ese: 30, total: 52 },
  { student_id: "R03", course_id: "M53", ise: 30, ese: 45, total: 75 },
  { student_id: "R04", course_id: "M52", ise: 38, ese: 54, total: 92 },
  { student_id: "R04", course_id: "M53", ise: 20, ese: 15, total: 35 }
])
 
// 1. Display exam records, highest total first
db.exams.find().sort({ total: -1 })
 
// 2. Students who failed in any course
db.exams.aggregate([
  { $match: { total: { $lt: 40 } } },
  { $lookup: { from: "students", localField: "student_id", foreignField: "_id", as: "student" } },
  { $unwind: "$student" },
  { $project: { _id: 0, student: "$student.name", course_id: 1, total: 1 } }
])
 
// 3. Course-wise average, highest and lowest total
db.exams.aggregate([
  { $group: {
      _id: "$course_id",
      average: { $avg: "$total" },
      highest: { $max: "$total" },
      lowest: { $min: "$total" }
  } }
])
 
// 4. Course-wise pass percentage
db.exams.aggregate([
  { $group: {
      _id: "$course_id",
      totalStudents: { $sum: 1 },
      passed: { $sum: { $cond: [{ $gte: ["$total", 40] }, 1, 0] } }
  } },
  { $project: {
      _id: 0,
      course_id: "$_id",
      passPercentage: { $multiply: [{ $divide: ["$passed", "$totalStudents"] }, 100] }
  } }
])
 
// 5. Topper of each course
db.exams.aggregate([
  { $sort: { course_id: 1, total: -1 } },
  { $group: { _id: "$course_id", topper: { $first: "$$ROOT" } } },
  { $lookup: { from: "students", localField: "topper.student_id", foreignField: "_id", as: "student" } },
  { $unwind: "$student" },
  { $project: { _id: 0, course_id: "$_id", student: "$student.name", total: "$topper.total" } }
])
 
// 6. Add grade field
db.exams.updateMany(
  {},
  [{
    $set: {
      grade: {
        $switch: {
          branches: [
            { case: { $gte: ["$total", 90] }, then: "O" },
            { case: { $gte: ["$total", 75] }, then: "A" },
            { case: { $gte: ["$total", 60] }, then: "B" },
            { case: { $gte: ["$total", 40] }, then: "C" }
          ],
          default: "F"
        }
      }
    }
  }]
)
 
// 7. Count students per grade in each course
db.exams.aggregate([
  { $group: { _id: { course: "$course_id", grade: "$grade" }, count: { $sum: 1 } } },
  { $sort: { "_id.course": 1, "_id.grade": 1 } }
])
 
// 8. Faculty-wise average marks
db.exams.aggregate([
  { $lookup: { from: "courses", localField: "course_id", foreignField: "_id", as: "course" } },
  { $unwind: "$course" },
  { $group: { _id: "$course.faculty", averageMarks: { $avg: "$total" } } }
])
 
// 9. Increase R01's M52 ESE by 5 and recompute total
db.exams.updateOne(
  { student_id: "R01", course_id: "M52" },
  [{ $set: { ese: { $add: ["$ese", 5] }, total: { $add: ["$ise", "$ese", 5] } } }]
)
 
db.exams.find({ student_id: "R01", course_id: "M52" })
 
// 10. Delete absent students' exam records
db.exams.deleteMany({ total: 0 })
