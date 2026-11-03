use libraryDB
 
db.books.insertMany([
  {
    _id: 1,
    title: "Database Systems",
    author: "Korth",
    genre: "Computer",
    copies: 5,
    year: 2019
  },
  {
    _id: 2,
    title: "Wings of Fire",
    author: "A. P. J. Abdul Kalam",
    genre: "Biography",
    copies: 3,
    year: 1999
  },
  {
    _id: 3,
    title: "Python Basics",
    author: "Rao",
    genre: "Computer",
    copies: 0,
    year: 2022
  }
])
 
db.members.insertMany([
  {
    _id: "M1",
    name: "Rutuja",
    borrowed: [
      { book_id: 1, date: ISODate("2026-10-05") }
    ]
  },
  {
    _id: "M2",
    name: "Siddhesh",
    borrowed: [
      { book_id: 1, date: ISODate("2026-10-12") },
      { book_id: 2, date: ISODate("2026-10-15") }
    ]
  }
])
 
db.books.find()
 
db.books.find({ genre: "Computer" })
 
db.books.find({
  year: { $gt: 2000 },
  copies: { $gt: 0 }
})
 
db.books.find(
  {},
  { title: 1, author: 1, _id: 0 }
).sort({ title: 1 })
 
db.members.find({ "borrowed.book_id": 1 })
 
db.books.updateOne(
  { title: "Python Basics" },
  { $inc: { copies: 2 } }
)
 
db.members.updateOne(
  { name: "Rutuja" },
  {
    $push: {
      borrowed: {
        book_id: 2,
        date: ISODate("2026-10-15")
      }
    }
  }
)
 
db.members.updateOne(
  { name: "Siddhesh" },
  { $pull: { borrowed: { book_id: 1 } } }
)
 
db.books.deleteOne({ title: "Wings of Fire" })
 
db.books.find()
