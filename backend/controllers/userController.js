const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const User = require('../models/userModel');

// Register user
const registerUser = async (req, res) => {
  try {
    const { username, email, password, userType, location, description } = req.body;

    if (!username || !email || !password || !userType) {
      return res.status(400).json({ message: "All fields are required" });
    }

    if (!['Student', 'Company'].includes(userType)) {
      return res.status(400).json({ message: "userType must be 'Student' or 'Company'" });
    }

    const existing = await User.findUserByEmail(email);
    if (existing.length > 0) {
      return res.status(400).json({ message: "Email already exists" });
    }

    const hashedPassword = await bcrypt.hash(password, 10);

    const result = await User.createUser(username, email, hashedPassword, userType, location, description);
    res.status(201).json({ message: "User registered", userID: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Login user
const loginUser = async (req, res) => {
  try {
    const { email, password } = req.body;

    const users = await User.findUserByEmail(email);
    if (users.length === 0) return res.status(400).json({ message: "Invalid credentials" });

    const user = users[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: "Invalid credentials" });

    const token = jwt.sign(
      { id: user.userID, userType: user.userType },
      process.env.JWT_SECRET,
      { expiresIn: '30d' }
    );

    res.json({ token });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = { registerUser, loginUser };
