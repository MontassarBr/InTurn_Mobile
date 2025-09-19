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

// Get all internships
const getAllInternships = async () => {
  const sql = `SELECT * FROM Internship`;
  const [rows] = await pool.query(sql);
  return rows;
};

// Get internship by ID
const getInternshipById = async (id) => {
  const sql = `SELECT * FROM Internship WHERE internshipID = ?`;
  const [rows] = await pool.query(sql, [id]);
  return rows;
};

// Update internship (only company who owns it)
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
  getAllInternships,
  getInternshipById,
  updateInternship,
  deleteInternship
};
