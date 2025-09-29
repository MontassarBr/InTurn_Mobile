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
  let sql = `
    SELECT i.*, c.companyName, c.industry 
    FROM Internship i 
    LEFT JOIN Company c ON i.companyID = c.companyID 
    WHERE i.status = 'Published'
  `;
  const values = [];

  // Filters
  if (filters.location) {
    sql += ` AND i.location = ?`;
    values.push(filters.location);
  }
  if (filters.workTime) {
    sql += ` AND i.workTime = ?`;
    values.push(filters.workTime);
  }
  if (filters.workArrangement) {
    sql += ` AND i.workArrangement = ?`;
    values.push(filters.workArrangement);
  }
  if (filters.payment) {
    sql += ` AND i.payment = ?`;
    values.push(filters.payment);
  }

  // Order by most recent
  sql += ` ORDER BY i.postedDate DESC`;

  // Pagination
  const limit = parseInt(filters.limit) || 20;   // default 20 per page
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

// Delete internship and related applications and saved internships
const deleteInternship = async (id) => {
  const connection = await pool.getConnection();
  
  try {
    // Start transaction
    await connection.beginTransaction();
    
    // First delete all saved internships for this internship
    const deleteSavedInternshipsSql = `DELETE FROM SavedInternship WHERE internshipID = ?`;
    await connection.query(deleteSavedInternshipsSql, [id]);
    
    // Then delete all applications for this internship
    const deleteApplicationsSql = `DELETE FROM Application WHERE internshipID = ?`;
    await connection.query(deleteApplicationsSql, [id]);
    
    // Finally delete the internship itself
    const deleteInternshipSql = `DELETE FROM Internship WHERE internshipID = ?`;
    const [result] = await connection.query(deleteInternshipSql, [id]);
    
    // Commit transaction
    await connection.commit();
    return result;
  } catch (error) {
    // Rollback transaction on error
    await connection.rollback();
    throw error;
  } finally {
    // Release connection
    connection.release();
  }
};

module.exports = {
  createInternship,
  getInternships,
  getInternshipById,
  updateInternship,
  deleteInternship
};
