const express = require("express");
const dotenv = require("dotenv");
const db = require("./config/db");
const userRoutes = require("./routes/userRoutes");
const internshipRoutes = require("./routes/internshipRoutes");
const applicationRoutes = require('./routes/applicationRoutes');
const studentRoutes = require('./routes/studentRoutes');
const companyRoutes = require('./routes/companyRoutes');
dotenv.config();
const app = express();

app.use(express.json());

// Routes
app.use("/api/users", userRoutes);
app.use("/api/internships", internshipRoutes); 
app.use('/api/applications', applicationRoutes);
app.use('/api/students', studentRoutes);
app.use('/api/companies', companyRoutes);
// Base route
app.get("/", (req, res) => {
  res.send("API is running...");
});

(async () => {
  try {
    await db.query("SELECT 1");
    console.log("MySQL Connected (using pool)...");
  } catch (err) {
    console.error("MySQL connection error:", err);
    process.exit(1);
  }
})();

const PORT = process.env.PORT || 5000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
