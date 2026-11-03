use appointmentDB
 
db.doctors.insertMany([
  { _id: "D1", name: "Dr. Kavita Joshi", specialization: "Cardiology", fee: 800, phone: "9890200001" },
  { _id: "D2", name: "Dr. Sameer Patil", specialization: "ENT", fee: 400, phone: "9890200002" },
  { _id: "D3", name: "Dr. Rekha Nair", specialization: "Pediatrics", fee: 500, phone: "9890200003" }
])
 
db.patients.insertMany([
  { _id: "PA1", name: "Mahesh Kale", age: 55, gender: "M", blood_group: "B+", contact: { phone: "9765200001", city: "Sangli" } },
  { _id: "PA2", name: "Shruti Deshmukh", age: 8, gender: "F", blood_group: "O+", contact: { phone: "9765200002", city: "Miraj" } },
  { _id: "PA3", name: "Ganesh Pawar", age: 37, gender: "M", blood_group: "AB+", contact: { phone: "9765200003", city: "Tasgaon" } }
])
 
db.appointments.insertMany([
  { _id: "A201", patient_id: "PA1", doctor_id: "D1", date: ISODate("2026-11-04T10:00:00Z"), status: "Scheduled" },
  { _id: "A202", patient_id: "PA2", doctor_id: "D3", date: ISODate("2026-11-04T11:00:00Z"), status: "Scheduled" },
  { _id: "A203", patient_id: "PA3", doctor_id: "D2", date: ISODate("2026-11-03T12:30:00Z"), status: "Completed" },
  { _id: "A204", patient_id: "PA1", doctor_id: "D2", date: ISODate("2026-11-05T09:30:00Z"), status: "Scheduled" }
])
 
// 1. Collection design:
// appointments.patient_id -> patients._id
// appointments.doctor_id -> doctors._id
 
// 2. Collections and data are created above.
 
// 3. Validate patient name and 10-digit phone
db.runCommand({
  collMod: "patients",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["name", "contact"],
      properties: {
        name: { bsonType: "string" },
        contact: {
          bsonType: "object",
          required: ["phone"],
          properties: {
            phone: { bsonType: "string", pattern: "^[0-9]{10}$" }
          }
        }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
})
 
// 4. This insert should fail because phone is missing
db.patients.insertOne({
  _id: "PA4",
  name: "Test Patient",
  age: 30,
  gender: "M",
  blood_group: "O+",
  contact: { city: "Pune" }
})
 
// 5. Doctors whose fee is above 450
db.doctors.find({ fee: { $gt: 450 } })
 
// 6. Book appointment for PA3 with D1 on 2026-11-06
db.appointments.insertOne({
  _id: "A205",
  patient_id: "PA3",
  doctor_id: "D1",
  date: ISODate("2026-11-06T10:00:00Z"),
  status: "Scheduled"
})
 
// 7. Appointments with patient and doctor names
db.appointments.aggregate([
  { $lookup: { from: "patients", localField: "patient_id", foreignField: "_id", as: "patient" } },
  { $lookup: { from: "doctors", localField: "doctor_id", foreignField: "_id", as: "doctor" } },
  { $unwind: "$patient" },
  { $unwind: "$doctor" },
  { $project: {
      _id: 1,
      date: 1,
      status: 1,
      patient_name: "$patient.name",
      doctor_name: "$doctor.name"
  } }
])
 
// 8. Appointments of Dr. Sameer Patil
db.appointments.aggregate([
  { $match: { doctor_id: "D2" } },
  { $lookup: { from: "doctors", localField: "doctor_id", foreignField: "_id", as: "doctor" } },
  { $unwind: "$doctor" },
  { $project: { _id: 1, patient_id: 1, date: 1, status: 1, doctor: "$doctor.name" } }
])
 
// 9. Cancel appointment A202
db.appointments.updateOne(
  { _id: "A202" },
  { $set: { status: "Cancelled" } }
)
 
// 10. Count appointments for each doctor
db.appointments.aggregate([
  { $group: { _id: "$doctor_id", appointmentCount: { $sum: 1 } } },
  { $lookup: { from: "doctors", localField: "_id", foreignField: "_id", as: "doctor" } },
  { $unwind: "$doctor" },
  { $project: { _id: 0, doctor: "$doctor.name", appointmentCount: 1 } }
])
