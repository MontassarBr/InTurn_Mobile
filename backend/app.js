// app.js
const express = require("express");       
const dotenv = require("dotenv");          
const db = require("./config/db");         
const userRoutes = require("./routes/userRoutes");

dotenv.config(); 
const app = express();
app.use(express.json());

app.use("/api/users", userRoutes);

app.get("/", (req, res) => {
  res.send("API is running...");
});


db.connect((err) => {
  if (err) {
    console.error("MySQL connection error:", err);
    process.exit(1); 
  }
  console.log("MySQL Connected...");
});

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
