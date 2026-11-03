use billingDB
 
db.doctors.insertMany([
  { _id: "DR7", name: "Dr. Anand Kulkarni", specialization: "Orthopedics", fee: 600 },
  { _id: "DR8", name: "Dr. Swati Mane", specialization: "Gynecology", fee: 700 }
])
 
db.patients.insertMany([
  { _id: "PB1", name: "Sunil Jagtap", age: 48, gender: "M", contact: { phone: "9765300001", city: "Kolhapur" } },
  { _id: "PB2", name: "Asha Kadam", age: 31, gender: "F", contact: { phone: "9765300002", city: "Ichalkaranji" } },
  { _id: "PB3", name: "Vinod Shirke", age: 66, gender: "M", contact: { phone: "9765300003", city: "Kolhapur" } }
])
 
db.appointments.insertMany([
  { _id: "B301", patient_id: "PB1", doctor_id: "DR7", date: ISODate("2026-11-02T10:00:00Z"), status: "Completed" },
  { _id: "B302", patient_id: "PB2", doctor_id: "DR8", date: ISODate("2026-11-02T12:00:00Z"), status: "Completed" },
  { _id: "B303", patient_id: "PB3", doctor_id: "DR7", date: ISODate("2026-11-03T10:30:00Z"), status: "Completed" }
])
 
db.prescriptions.insertMany([
  {
    _id: "RX11",
    appointment_id: "B301",
    patient_id: "PB1",
    diagnosis: "Knee arthritis",
    medicines: [{ name: "Diclofenac 50", dose: "1-0-1", days: 10 }, { name: "Calcium 500", dose: "0-0-1", days: 30 }]
  },
  {
    _id: "RX12",
    appointment_id: "B302",
    patient_id: "PB2",
    diagnosis: "Anaemia",
    medicines: [{ name: "Iron Folic Acid", dose: "0-0-1", days: 60 }]
  },
  {
    _id: "RX13",
    appointment_id: "B303",
    patient_id: "PB3",
    diagnosis: "Back pain",
    medicines: [{ name: "Diclofenac 50", dose: "1-0-1", days: 5 }, { name: "Pantoprazole 40", dose: "1-0-0", days: 5 }]
  }
])
 
db.billing.insertMany([
  {
    _id: "BL11",
    patient_id: "PB1",
    appointment_id: "B301",
    items: [{ description: "Consultation", amount: 600 }, { description: "X-ray", amount: 450 }],
    total: 1050,
    status: "Paid"
  },
  {
    _id: "BL12",
    patient_id: "PB2",
    appointment_id: "B302",
    items: [{ description: "Consultation", amount: 700 }, { description: "Blood test", amount: 300 }],
    total: 1000,
    status: "Pending"
  }
])
 
// 1. Collections and records created above.
 
// 2. Validate total and status
db.runCommand({
  collMod: "billing",
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["total", "status"],
      properties: {
        total: { bsonType: ["int", "long", "double", "decimal"], minimum: 0 },
        status: { enum: ["Paid", "Pending", "Cancelled"] }
      }
    }
  },
  validationLevel: "strict",
  validationAction: "error"
})
 
// 3. This insert should fail because total is negative
db.billing.insertOne({
  _id: "BL13",
  patient_id: "PB3",
  appointment_id: "B303",
  items: [],
  total: -200,
  status: "Paid"
})
 
// 4. Prescription of PB1 with medicines
db.prescriptions.find({ patient_id: "PB1" })
 
// 5. Add Vitamin D3 to RX12
db.prescriptions.updateOne(
  { _id: "RX12" },
  { $push: { medicines: { name: "Vitamin D3", dose: "0-0-1", days: 30 } } }
)
 
// 6. List each medicine with number of times it appears
db.prescriptions.aggregate([
  { $unwind: "$medicines" },
  { $group: { _id: "$medicines.name", timesPrescribed: { $sum: 1 } } },
  { $sort: { timesPrescribed: -1 } }
])
 
// 7. Generate bill for B303 using doctor's consultation fee
db.appointments.aggregate([
  { $match: { _id: "B303" } },
  { $lookup: { from: "doctors", localField: "doctor_id", foreignField: "_id", as: "doctor" } },
  { $unwind: "$doctor" },
  { $project: {
      _id: 0,
      bill_id: "BL13",
      patient_id: 1,
      appointment_id: "$_id",
      items: [{ description: "Consultation", amount: "$doctor.fee" }],
      total: "$doctor.fee",
      status: "Pending"
  } },
  { $merge: { into: "billing", whenMatched: "replace", whenNotMatched: "insert" } }
])
 
// 8. Pending bills with patient name and phone
db.billing.aggregate([
  { $match: { status: "Pending" } },
  { $lookup: { from: "patients", localField: "patient_id", foreignField: "_id", as: "patient" } },
  { $unwind: "$patient" },
  { $project: { _id: 1, total: 1, patient_name: "$patient.name", phone: "$patient.contact.phone" } }
])
 
// 9. Total collected and total pending
db.billing.aggregate([
  { $group: {
      _id: "$status",
      amount: { $sum: "$total" }
  } }
])
 
// 10. Mark BL12 as Paid and display all bills
db.billing.updateOne(
  { _id: "BL12" },
  { $set: { status: "Paid" } }
)
 
db.billing.find()
