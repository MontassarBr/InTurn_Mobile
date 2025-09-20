// models/internshipModel.js
const pool = require('../config/db');

// Create new internship
const createInternship = async (companyID, title, startDate, endDate, minSalary, maxSalary, description, location, payment, workArrangement, workTime, status = 'Pending') => {
  const sql = `
    INSERT INTO Internship
    (companyID, title, startDate, endDate, minSalary, maxSalary, description, location, payment, workArrangement, workTime, status)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
  `;
  const [result] = await pool.query(sql, [
    companyID, title, startDate, endDate, minSalary, maxSalary, description, location, payment, workArrangement, workTime, status
  ]);
  return result;
};

// Get internships with optional filters and pagination
const getInternships = async (filters) => {
  let sql = `SELECT * FROM Internship WHERE 1=1`; // 1=1 allows easy concatenation
  const values = [];

  // Filters
  if (filters.location) {
    sql += ` AND location = ?`;
    values.push(filters.location);
  }
  if (filters.workTime) {
    sql += ` AND workTime = ?`;
    values.push(filters.workTime);
  }
  if (filters.workArrangement) {
    sql += ` AND workArrangement = ?`;
    values.push(filters.workArrangement);
  }
  if (filters.payment) {
    sql += ` AND payment = ?`;
    values.push(filters.payment);
  }

  // Pagination
  const limit = parseInt(filters.limit) || 10;   // default 10 per page
  const offset = parseInt(filters.offset) || 0;  // default start at 0
  sql += ` LIMIT ? OFFSET ?`;
  values.push(limit, offset);

  const [rows] = await pool.query(sql, values);
  return rows;
};

// Get internship by ID
const getInternshipById = async (id) => {
  const sql = `SELECT * FROM Internship WHERE internshipID = ?`;
  const [rows] = await pool.query(sql, [id]);
  return rows[0]; // return single object instead of array
};

// Update internship
const updateInternship = async (id, data) => {
  const fields = [];
  const values = [];

  for (const key in data) {
    fields.push(`${key} = ?`);
    values.push(data[key]);
  }

  const sql = `UPDATE Internship SET ${fields.join(', ')} WHERE internshipID = ?`;
  values.push(id);

  const [result] = await pool.query(sql, values);
  return result;
};

// Delete internship
const deleteInternship = async (id) => {
  const sql = `DELETE FROM Internship WHERE internshipID = ?`;
  const [result] = await pool.query(sql, [id]);
  return result;
};

module.exports = {
  createInternship,
  getInternships,
  getInternshipById,
  updateInternship,
  deleteInternship
};
