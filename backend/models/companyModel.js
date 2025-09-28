const pool = require('../config/db');

// Get company profile by userID
const getCompanyById = async (companyID) => {
  const sql = `SELECT * FROM Company WHERE companyID = ?`;
  const [rows] = await pool.query(sql, [companyID]);
  return rows[0];
};

// Update company profile
const updateCompany = async (companyID, data) => {
  const fields = Object.keys(data);
  const values = Object.values(data);

  if (fields.length === 0) return;

  const setClause = fields.map(f => `${f} = ?`).join(", ");
  const sql = `UPDATE Company SET ${setClause} WHERE companyID = ?`;
  await pool.query(sql, [...values, companyID]);
};

// Add company benefit
const addBenefit = async (companyID, benefit) => {
  const sql = `INSERT INTO CompanyBenefit (companyID, benefit) VALUES (?, ?)`;
  await pool.query(sql, [companyID, benefit]);
};

// Get full company profile including benefits
const getFullProfile = async (companyID) => {
  // Basic company info
  const [companyRows] = await pool.query(`SELECT * FROM Company WHERE companyID = ?`, [companyID]);
  if (companyRows.length === 0) return null;
  const company = companyRows[0];

  // Benefits
  const [benefits] = await pool.query(`SELECT benefit FROM CompanyBenefit WHERE companyID = ?`, [companyID]);

  return {
    ...company,
    benefits: benefits.map(b => b.benefit)
  };
};

const deleteBenefit = async (companyID, benefit) => {
  const sql = `DELETE FROM CompanyBenefit WHERE companyID = ? AND benefit = ?`;
  await pool.query(sql, [companyID, benefit]);
};

// Get all companies for public directory
const getAllCompanies = async () => {
  const sql = `
    SELECT c.companyID, c.companyName, c.website, c.industry, u.description, u.location
    FROM Company c
    JOIN User u ON c.companyID = u.userID
    WHERE u.userType = 'Company'
    ORDER BY c.companyName ASC
  `;
  const [rows] = await pool.query(sql);
  return rows;
};

module.exports = {
  getCompanyById,
  updateCompany,
  addBenefit,
  deleteBenefit,
  getFullProfile,
  getAllCompanies
};
