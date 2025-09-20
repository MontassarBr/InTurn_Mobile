const pool = require('../config/db');

// Create a new application
const createApplication = async (studentID, internshipID, status = 'Pending') => {
  const sql = `
    INSERT INTO Application (studentID, internshipID, applicationDate, status)
    VALUES (?, ?, NOW(), ?)
  `;
  const [result] = await pool.query(sql, [studentID, internshipID, status]);
  return result;
};

// Get all applications
const getAllApplications = async () => {
  const sql = `SELECT * FROM Application`;
  const [rows] = await pool.query(sql);
  return rows;
};

// Get applications by student
const getApplicationsByStudent = async (studentID) => {
  const sql = `SELECT * FROM Application WHERE studentID = ?`;
  const [rows] = await pool.query(sql, [studentID]);
  return rows;
};

// Get applications by internship
const getApplicationsByInternship = async (internshipID) => {
  const sql = `SELECT * FROM Application WHERE internshipID = ?`;
  const [rows] = await pool.query(sql, [internshipID]);
  return rows;
};

// Update application status
const updateApplicationStatus = async (studentID, internshipID, applicationDate, status) => {
  const sql = `
    UPDATE Application
    SET status = ?
    WHERE studentID = ? AND internshipID = ? AND applicationDate = ?
  `;
  const [result] = await pool.query(sql, [status, studentID, internshipID, applicationDate]);
  return result;
};

module.exports = {
  createApplication,
  getAllApplications,
  getApplicationsByStudent,
  getApplicationsByInternship,
  updateApplicationStatus
};
