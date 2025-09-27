const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/userModel");

// Register user
const registerUser = async (req, res) => {
  try {
    const { email, password, userType, location, description, profilePic, firstName, lastName, companyName } = req.body;

    if (!email || !password || !userType) {
      return res.status(400).json({ message: "Email, password, and userType are required" });
    }

    if (!["Student", "Company"].includes(userType)) {
      return res.status(400).json({ message: "userType must be 'Student' or 'Company'" });
    }

    // Check if email already exists
    const existing = await User.findUserByEmail(email);
    if (existing.length > 0) {
      return res.status(400).json({ message: "Email already exists" });
    }

    // Hash password
    const hashedPassword = await bcrypt.hash(password, 10);

    // Save user in User table
    const result = await User.createUser(email, hashedPassword, userType, location || null, description || null, profilePic || null);
    const userID = result.insertId;

    // Insert into Student or Company
    if (userType === "Student") {
      await User.createStudent(userID, firstName || "", lastName || "");
    } else if (userType === "Company") {
      await User.createCompany(userID, companyName || "");
    }

    // Generate JWT token so the user can be logged in immediately
    const token = jwt.sign(
      { id: userID, userType },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.status(201).json({
      message: "User registered successfully",
      token,
      user: {
        userID,
        email,
        userType,
        location: location || null,
        description: description || null,
        profilePic: profilePic || null,
      },
    });
  } catch (err) {
    console.error("Error registering user:", err);
    res.status(500).json({ message: "Server error" });
  }
};

// Login user
const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    if (!email || !password) {
      return res.status(400).json({ message: "Email and password are required" });
    }

    const users = await User.findUserByEmail(email);
    if (users.length === 0) return res.status(400).json({ message: "Invalid credentials" });

    const user = users[0];

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: "Invalid credentials" });

    const token = jwt.sign(
      { id: user.userID, userType: user.userType },
      process.env.JWT_SECRET,
      { expiresIn: "7d" }
    );

    res.json({
      message: "Login successful",
      token,
      user: {
        userID: user.userID,
        email: user.email,
        userType: user.userType,
        location: user.location,
        description: user.description,
        profilePic: user.profilePic,
      },
    });
  } catch (err) {
    console.error("Error logging in:", err);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = { registerUser, loginUser };
