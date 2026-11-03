use reportDB
 
db.students.insertMany([
  { _id: "G01", name: "Om Chavan", gender: "M", dept: "CSE", semester: 3, contact: { phone: "9833300001", city: "Sangli" } },
  { _id: "G02", name: "Pooja Rane", gender: "F", dept: "CSE", semester: 3, contact: { phone: "9833300002", city: "Pune" } },
  { _id: "G03", name: "Rahul Salunkhe", gender: "M", dept: "CSE", semester: 3, contact: { phone: "9833300003", city: "Satara" } }
])
 
db.courses.insertMany([
  { _id: "D31", name: "Data Structures", credits: 4, faculty: "Dr. Joshi" },
  { _id: "D32", name: "OOP with Java", credits: 4, faculty: "Dr. Naik" },
  { _id: "D33", name: "Digital Electronics", credits: 3, faculty: "Dr. Kulkarni" }
])
 
db.attendance.insertMany([
  { student_id: "G01", course_id: "D31", total: 40, attended: 36 },
  { student_id: "G01", course_id: "D32", total: 40, attended: 34 },
  { student_id: "G01", course_id: "D33", total: 30, attended: 27 },
  { student_id: "G02", course_id: "D31", total: 40, attended: 29 },
  { student_id: "G02", course_id: "D32", total: 40, attended: 38 },
  { student_id: "G02", course_id: "D33", total: 30, attended: 28 },
  { student_id: "G03", course_id: "D31", total: 40, attended: 33 },
  { student_id: "G03", course_id: "D32", total: 40, attended: 31 },
  { student_id: "G03", course_id: "D33", total: 30, attended: 20 }
])
 
db.exams.insertMany([
  { student_id: "G01", course_id: "D31", ise: 35, ese: 55, total: 90 },
  { student_id: "G01", course_id: "D32", ise: 30, ese: 48, total: 78 },
  { student_id: "G01", course_id: "D33", ise: 28, ese: 40, total: 68 },
  { student_id: "G02", course_id: "D31", ise: 20, ese: 25, total: 45 },
  { student_id: "G02", course_id: "D32", ise: 36, ese: 52, total: 88 },
  { student_id: "G02", course_id: "D33", ise: 32, ese: 44, total: 76 },
  { student_id: "G03", course_id: "D31", ise: 18, ese: 16, total: 34 },
  { student_id: "G03", course_id: "D32", ise: 25, ese: 35, total: 60 },
  { student_id: "G03", course_id: "D33", ise: 27, ese: 38, total: 65 }
])
 
// Common report pipeline
const reportPipeline = [
  { $lookup: { from: "students", localField: "student_id", foreignField: "_id", as: "student" } },
  { $unwind: "$student" },
  { $lookup: { from: "courses", localField: "course_id", foreignField: "_id", as: "course" } },
  { $unwind: "$course" },
  { $lookup: {
      from: "attendance",
      let: { sid: "$student_id", cid: "$course_id" },
      pipeline: [
        { $match: { $expr: { $and: [
          { $eq: ["$student_id", "$$sid"] },
          { $eq: ["$course_id", "$$cid"] }
        ] } } }
      ],
      as: "attendance"
  } },
  { $unwind: "$attendance" },
  { $set: {
      attendancePercentage: {
        $multiply: [{ $divide: ["$attendance.attended", "$attendance.total"] }, 100]
      },
      grade: {
        $switch: {
          branches: [
            { case: { $gte: ["$total", 90] }, then: "O" },
            { case: { $gte: ["$total", 80] }, then: "A" },
            { case: { $gte: ["$total", 70] }, then: "B" },
            { case: { $gte: ["$total", 40] }, then: "C" }
          ],
          default: "F"
        }
      }
  } },
  { $project: {
      _id: 0,
      student_id: 1,
      name: "$student.name",
      course_id: 1,
      course: "$course.name",
      credits: "$course.credits",
      ise: 1,
      ese: 1,
      total: 1,
      attendancePercentage: 1,
      grade: 1
  } }
]
 
// 1. List each student's courses with marks
db.exams.aggregate(reportPipeline)
 
// 2. Join students, courses, exams and attendance
db.exams.aggregate(reportPipeline)
 
// 3. Name, course, marks, attendance percentage and grade
db.exams.aggregate(reportPipeline)
 
// 4. Calculate SGPA using O=10, A=9, B=8, C=6, F=0
db.exams.aggregate([
  ...reportPipeline,
  { $set: {
      gradePoint: {
        $switch: {
          branches: [
            { case: { $eq: ["$grade", "O"] }, then: 10 },
            { case: { $eq: ["$grade", "A"] }, then: 9 },
            { case: { $eq: ["$grade", "B"] }, then: 8 },
            { case: { $eq: ["$grade", "C"] }, then: 6 }
          ],
          default: 0
        }
      }
  } },
  { $group: {
      _id: "$student_id",
      name: { $first: "$name" },
      weightedPoints: { $sum: { $multiply: ["$gradePoint", "$credits"] } },
      totalCredits: { $sum: "$credits" }
  } },
  { $project: {
      _id: 0,
      student_id: "$_id",
      name: 1,
      SGPA: { $divide: ["$weightedPoints", "$totalCredits"] }
  } }
])
 
// 5. Class topper by SGPA
db.exams.aggregate([
  ...reportPipeline,
  { $set: {
      gradePoint: {
        $switch: {
          branches: [
            { case: { $eq: ["$grade", "O"] }, then: 10 },
            { case: { $eq: ["$grade", "A"] }, then: 9 },
            { case: { $eq: ["$grade", "B"] }, then: 8 },
            { case: { $eq: ["$grade", "C"] }, then: 6 }
          ],
          default: 0
        }
      }
  } },
  { $group: {
      _id: "$student_id",
      name: { $first: "$name" },
      weightedPoints: { $sum: { $multiply: ["$gradePoint", "$credits"] } },
      totalCredits: { $sum: "$credits" }
  } },
  { $set: { SGPA: { $divide: ["$weightedPoints", "$totalCredits"] } } },
  { $sort: { SGPA: -1 } },
  { $limit: 1 }
])
 
// 6. Report card of G02
db.exams.aggregate([
  { $match: { student_id: "G02" } },
  ...reportPipeline
])
 
// 7. Pass or Fail for each student
db.exams.aggregate([
  ...reportPipeline,
  { $group: {
      _id: "$student_id",
      name: { $first: "$name" },
      failedCourses: { $sum: { $cond: [{ $lt: ["$total", 40] }, 1, 0] } }
  } },
  { $project: {
      _id: 0,
      student_id: "$_id",
      name: 1,
      result: { $cond: [{ $gt: ["$failedCourses", 0] }, "Fail", "Pass"] }
  } }
])
 
// 8. Add Detained remark if any course attendance is below 75%
db.exams.aggregate([
  ...reportPipeline,
  { $group: {
      _id: "$student_id",
      name: { $first: "$name" },
      lowAttendanceCourses: {
        $sum: { $cond: [{ $lt: ["$attendancePercentage", 75] }, 1, 0] }
      }
  } },
  { $project: {
      _id: 0,
      student_id: "$_id",
      name: 1,
      remark: { $cond: [{ $gt: ["$lowAttendanceCourses", 0] }, "Detained", "Eligible"] }
  } }
])
 
// 9. Save report to report_cards
db.exams.aggregate([
  ...reportPipeline,
  { $out: "report_cards" }
])
 
// 10. Export from terminal:
// mongoexport --db=reportDB --collection=report_cards --type=csv --fields=student_id,name,course_id,course,ise,ese,total,attendancePercentage,grade --out=report_cards.csv
