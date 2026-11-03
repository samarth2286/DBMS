use foodDB
 
db.restaurants.insertMany([
  {
    _id: "R1",
    name: "Spice Hub",
    city: "Sangli",
    cuisine: "North Indian",
    rating: 4.3,
    menu: [
      { item: "Paneer Tikka", price: 220 },
      { item: "Dal Makhani", price: 180 }
    ]
  },
  {
    _id: "R2",
    name: "Dosa Corner",
    city: "Pune",
    cuisine: "South Indian",
    rating: 4.6,
    menu: [
      { item: "Masala Dosa", price: 90 },
      { item: "Idli", price: 60 }
    ]
  },
  {
    _id: "R3",
    name: "Pizza Point",
    city: "Sangli",
    cuisine: "Italian",
    rating: 3.9,
    menu: [
      { item: "Margherita", price: 250 }
    ]
  }
])
 
db.restaurants.insertOne({
  _id: "R4",
  name: "Burger House",
  city: "Mumbai",
  cuisine: "Fast Food",
  rating: 4.2,
  menu: [{ item: "Veg Burger", price: 120 }]
})
 
db.restaurants.find()
 
db.restaurants.find({ city: "Sangli" })
 
db.restaurants.find(
  { rating: { $gt: 4 } },
  { name: 1, rating: 1, _id: 0 }
)
 
db.restaurants.find().sort({ rating: -1 })
 
db.restaurants.updateOne(
  { name: "Pizza Point" },
  { $set: { rating: 4.1 } }
)
 
db.restaurants.updateOne(
  { name: "Spice Hub" },
  { $push: { menu: { item: "Veg Biryani", price: 200 } } }
)
 
db.restaurants.updateMany(
  {},
  { $set: { is_open: true } }
)
 
db.restaurants.deleteMany({ rating: { $lt: 4 } })
 
db.restaurants.countDocuments({})
