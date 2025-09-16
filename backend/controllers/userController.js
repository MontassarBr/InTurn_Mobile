const bcrypt = require("bcryptjs");
const jwt = require("jsonwebtoken");
const User = require("../models/userModel");

const registerUser = (req, res) => {
  const { name, email, password } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ message: "Please fill all fields" });
  }

  User.findUserByEmail(email, async (err, results) => {
    if (err) return res.status(500).json({ message: "Database error" });

    if (results.length > 0) {
      return res.status(400).json({ message: "User already exists" });
    }
    const salt = await bcrypt.genSalt(10);
    const hashedPassword = await bcrypt.hash(password, salt);

    User.createUser(name, email, hashedPassword, (err, result) => {
      if (err) return res.status(500).json({ message: "Database error" });
      return res.status(201).json({ message: "User registered successfully" });
    });
  });
};

const loginUser = (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) return res.status(400).json({ message: "Provide email and password" });

  User.findUserByEmail(email, async (err, results) => {
    if (err) return res.status(500).json({ message: "Database error" });
    if (results.length === 0) return res.status(400).json({ message: "Invalid email or password" });

    const user = results[0];

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return res.status(400).json({ message: "Invalid email or password" });


    const token = jwt.sign({ id: user.id }, process.env.JWT_SECRET, { expiresIn: "30d" });

    return res.json({ id: user.id, name: user.name, email: user.email, token });
  });
};

module.exports = { registerUser, loginUser };
