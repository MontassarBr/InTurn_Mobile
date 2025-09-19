// models/userModel.js
const pool = require('../config/db');

// Create a new user (Student or Company)
const createUser = async (username, email, hashedPassword, userType, location = null, description = null, profilePic = null) => {
  const sql = `
    INSERT INTO User (username, email, password, userType, location, description, profilePic)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `;
  const [result] = await pool.query(sql, [username, email, hashedPassword, userType, location, description, profilePic]);
  return result;
};

// Find user by email
const findUserByEmail = async (email) => {
  const sql = `SELECT * FROM User WHERE email = ?`;
  const [rows] = await pool.query(sql, [email]);
  return rows;
};

// Find user by ID 
const findUserById = async (id) => {
  const sql = `SELECT userID, username, email, userType, location, description, profilePic FROM User WHERE userID = ?`;
  const [rows] = await pool.query(sql, [id]);
  return rows;
};

module.exports = { createUser, findUserByEmail, findUserById };
