const express = require("express");
const cors = require("cors");
const dotenv = require("dotenv");
const db = require("./config/db");
const userRoutes = require("./routes/userRoutes");
const internshipRoutes = require("./routes/internshipRoutes");
const applicationRoutes = require('./routes/applicationRoutes');
const studentRoutes = require('./routes/studentRoutes');
const companyRoutes = require('./routes/companyRoutes');
dotenv.config();
const app = express();

// Middleware
app.use(cors({
  origin: ['http://localhost:3000', 'http://10.0.2.2:3000', 'http://127.0.0.1:3000'],
  credentials: true
}));
app.use(express.json());

// Routes
app.use("/api/users", userRoutes);
app.use("/api/internships", internshipRoutes); 
app.use('/api/applications', applicationRoutes);
app.use('/api/students', studentRoutes);
app.use('/api/companies', companyRoutes);
// Debug middleware to log all requests
app.use((req, res, next) => {
  console.log(`${new Date().toISOString()} - ${req.method} ${req.originalUrl}`);
  next();
});

// Base route
app.get("/", (req, res) => {
  res.send("API is running...");
});

// Health check route
app.get("/api/health", (req, res) => {
  res.json({ 
    status: "OK", 
    timestamp: new Date().toISOString(),
    message: "InTurn API is running successfully" 
  });
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
