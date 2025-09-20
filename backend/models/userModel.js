const pool = require('../config/db');

// Create a new user
const createUser = async (email, hashedPassword, userType, location = null, description = null, profilePic = null) => {
  const sql = `
    INSERT INTO User (email, password, userType, location, description, profilePic)
    VALUES (?, ?, ?, ?, ?, ?)
  `;
  const [result] = await pool.query(sql, [email, hashedPassword, userType, location, description, profilePic]);
  return result; // contains insertId = userID
};

// Create student 
const createStudent = async (userID, firstName = "", lastName = "") => {
  const sql = `
    INSERT INTO Student (studentID, firstName, lastName)
    VALUES (?, ?, ?)
  `;
  const [result] = await pool.query(sql, [userID, firstName, lastName]);
  return result;
};

// Create company 
const createCompany = async (userID, companyName = "") => {
  const sql = `
    INSERT INTO Company (companyID, companyName)
    VALUES (?, ?)
  `;
  const [result] = await pool.query(sql, [userID, companyName]);
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
  const sql = `SELECT userID, email, userType, location, description, profilePic 
               FROM User WHERE userID = ?`;
  const [rows] = await pool.query(sql, [id]);
  return rows;
};

module.exports = { createUser, createStudent, createCompany, findUserByEmail, findUserById };
