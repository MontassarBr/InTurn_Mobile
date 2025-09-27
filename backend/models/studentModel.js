const pool = require('../config/db');

// Get basic student profile by userID
const getStudentById = async (studentID) => {
  const sql = `SELECT * FROM Student WHERE studentID = ?`;
  const [rows] = await pool.query(sql, [studentID]);
  return rows[0];
};

// Update student profile
const updateStudent = async (studentID, data) => {
  const fields = Object.keys(data);
  const values = Object.values(data);

  if (fields.length === 0) return;

  const setClause = fields.map(f => `${f} = ?`).join(", ");
  const sql = `UPDATE Student SET ${setClause} WHERE studentID = ?`;
  await pool.query(sql, [...values, studentID]);
};

// Add education
const addEducation = async (studentID, education) => {
  const { institution, diploma, location, startDate, endDate } = education;
  const sql = `
    INSERT INTO Education (studentID, institution, diploma, location, startDate, endDate)
    VALUES (?, ?, ?, ?, ?, ?)
  `;
  await pool.query(sql, [studentID, institution, diploma, location, startDate, endDate]);
};

// Add skill
const addSkill = async (studentID, skill) => {
  const sql = `INSERT INTO Skills (studentID, skill) VALUES (?, ?)`;
  await pool.query(sql, [studentID, skill]);
};

// Add professional experience
const addProExperience = async (studentID, experience) => {
  const { title, startDate, endDate, employmentType, companyName, description } = experience;
  const sql = `
    INSERT INTO ProExperience (studentID, title, startDate, endDate, employmentType, companyName, description)
    VALUES (?, ?, ?, ?, ?, ?, ?)
  `;
  await pool.query(sql, [studentID, title, startDate, endDate, employmentType, companyName, description]);
};

// Get full student profile (basic info + education + skills + experience)
const getFullProfile = async (studentID) => {
  // Basic student info
  const [studentRows] = await pool.query(`SELECT * FROM Student WHERE studentID = ?`, [studentID]);
  if (studentRows.length === 0) return null;
  const student = studentRows[0];

  // Education
  const [education] = await pool.query(`SELECT * FROM Education WHERE studentID = ?`, [studentID]);

  // Skills
  const [skills] = await pool.query(`SELECT skill FROM Skills WHERE studentID = ?`, [studentID]);

  // Professional experience
  const [experience] = await pool.query(`SELECT * FROM ProExperience WHERE studentID = ?`, [studentID]);

  return {
    ...student,
    education,
    skills: skills.map(s => s.skill),
    experience
  };
};

const deleteEducation = async (studentID, institution, diploma) => {
  const sql = `DELETE FROM Education WHERE studentID = ? AND institution = ? AND diploma = ?`;
  await pool.query(sql, [studentID, institution, diploma]);
};

const deleteSkill = async (studentID, skill) => {
  const sql = `DELETE FROM Skills WHERE studentID = ? AND skill = ?`;
  await pool.query(sql, [studentID, skill]);
};

const deleteProExperience = async (experienceID, studentID) => {
  const sql = `DELETE FROM ProExperience WHERE experienceID = ? AND studentID = ?`;
  await pool.query(sql, [experienceID, studentID]);
};

module.exports = { 
  getStudentById, 
  updateStudent, 
  addEducation, 
  addSkill, 
  addProExperience,
  deleteEducation,
  deleteSkill,
  deleteProExperience,
  getFullProfile 
};
