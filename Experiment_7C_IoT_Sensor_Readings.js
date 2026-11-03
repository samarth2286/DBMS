use iotDB
 
db.readings.insertMany([
  {
    sensor_id: "T1",
    location: "Lab-1",
    type: "temperature",
    value: 28.5,
    time: ISODate("2026-11-01T09:00:00Z")
  },
  {
    sensor_id: "T1",
    location: "Lab-1",
    type: "temperature",
    value: 31.2,
    time: ISODate("2026-11-01T12:00:00Z")
  },
  {
    sensor_id: "H1",
    location: "Lab-1",
    type: "humidity",
    value: 62,
    time: ISODate("2026-11-01T09:00:00Z")
  },
  {
    sensor_id: "T2",
    location: "Lab-2",
    type: "temperature",
    value: 26.8,
    time: ISODate("2026-11-01T09:00:00Z")
  },
  {
    sensor_id: "H2",
    location: "Lab-2",
    type: "humidity",
    value: 70,
    time: ISODate("2026-11-01T12:00:00Z")
  }
])
 
db.readings.find()
 
db.readings.find({ type: "temperature" })
 
db.readings.find({
  type: "temperature",
  value: { $gt: 30 }
})
 
db.readings.find(
  { location: "Lab-2" },
  { sensor_id: 1, value: 1, _id: 0 }
).sort({ time: 1 })
 
db.readings.countDocuments({ location: "Lab-1" })
 
db.readings.updateMany(
  { type: "temperature" },
  { $set: { unit: "C" } }
)
 
db.readings.updateMany(
  { type: "humidity" },
  { $set: { unit: "%" } }
)
 
db.readings.updateOne(
  { sensor_id: "H2" },
  { $set: { value: 68 } }
)
 
db.readings.updateMany(
  {},
  { $rename: { value: "reading" } }
)
 
db.readings.deleteMany({
  time: { $lt: ISODate("2026-11-01T10:00:00Z") }
})
 
db.readings.countDocuments({})
