const pool = require('../config/db');

// Create a new application
const createApplication = async (studentID, internshipID, status = 'Pending') => {
  const sql = `
    INSERT INTO Application (studentID, internshipID, applicationDate, status)
    VALUES (?, ?, CURDATE(), ?)
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

// Get applications by student with internship details
const getApplicationsByStudent = async (studentID) => {
  const sql = `
    SELECT a.*, i.title, i.location, i.companyID, c.companyName, i.minSalary, i.maxSalary
    FROM Application a 
    LEFT JOIN Internship i ON a.internshipID = i.internshipID
    LEFT JOIN Company c ON i.companyID = c.companyID
    WHERE a.studentID = ?
    ORDER BY a.applicationDate DESC
  `;
  const [rows] = await pool.query(sql, [studentID]);
  return rows;
};

// Get applications by internship
const getApplicationsByInternship = async (internshipID) => {
  const sql = `SELECT * FROM Application WHERE internshipID = ?`;
  const [rows] = await pool.query(sql, [internshipID]);
  return rows;
};

// Get applications by company (all internships of a company) with full student details
const getApplicationsByCompany = async (companyID) => {
  const sql = `
    SELECT 
      a.studentID,
      a.internshipID, 
      a.applicationDate,
      a.status,
      i.title,
      i.location,
      i.minSalary,
      i.maxSalary,
      c.companyID,
      c.companyName,
      s.firstName,
      s.lastName,
      u.email,
      s.phone,
      s.about as aboutMe,
      s.university,
      s.degree,
      s.graduationYear,
      s.gpa,
      s.portfolioUrl,
      s.linkedinUrl,
      s.githubUrl
    FROM Application a
    LEFT JOIN Internship i ON a.internshipID = i.internshipID
    LEFT JOIN Company c ON i.companyID = c.companyID
    LEFT JOIN Student s ON a.studentID = s.studentID
    LEFT JOIN User u ON s.studentID = u.userID
    WHERE i.companyID = ?
    ORDER BY a.applicationDate DESC
  `;
  const [rows] = await pool.query(sql, [companyID]);
  
  // Get skills and experience for each student
  for (let row of rows) {
    // Get skills
    const skillsResult = await pool.query(
      'SELECT skill FROM Skills WHERE studentID = ?',
      [row.studentID]
    );
    row.skills = skillsResult[0].map(s => s.skill).join(',');
    
    // Get experience
    const expResult = await pool.query(`
      SELECT title, companyName, description, startDate, endDate, employmentType
      FROM ProExperience 
      WHERE studentID = ? 
      ORDER BY startDate DESC
    `, [row.studentID]);
    row.experience = JSON.stringify(expResult[0].map(exp => ({
      title: exp.title,
      company: exp.companyName,
      duration: `${exp.startDate} - ${exp.endDate || 'Present'}`,
      description: exp.description,
      type: exp.employmentType
    })));
    
    // Get education
    const eduResult = await pool.query(`
      SELECT institution, diploma, location, startDate, endDate, gpa, courses
      FROM Education 
      WHERE studentID = ? 
      ORDER BY startDate DESC
    `, [row.studentID]);
    row.education = JSON.stringify(eduResult[0].map(edu => ({
      institution: edu.institution,
      degree: edu.diploma,
      location: edu.location,
      duration: `${edu.startDate} - ${edu.endDate || 'Present'}`,
      gpa: edu.gpa ? `${edu.gpa}/4.0` : null,
      courses: edu.courses
    })));
  }
  
  return rows;
};

// Update application status
const updateApplicationStatus = async (studentID, internshipID, applicationDate, status) => {
  // Convert datetime string to date format for MySQL DATE column
  let dateForQuery = applicationDate;
  
  // If applicationDate is a full datetime string, extract just the date part
  if (typeof applicationDate === 'string' && applicationDate.includes('T')) {
    dateForQuery = applicationDate.split('T')[0]; // Extract YYYY-MM-DD part
  }
  
  console.log(`Updating application status: studentID=${studentID}, internshipID=${internshipID}, status=${status}`);
  
  // Use simple update by studentID and internshipID (works best)
  const sql = `
    UPDATE Application
    SET status = ?
    WHERE studentID = ? AND internshipID = ?
  `;
  const [result] = await pool.query(sql, [status, studentID, internshipID]);
  
  if (result.affectedRows === 0) {
    throw new Error(`No application found with studentID=${studentID}, internshipID=${internshipID}`);
  }
  
  console.log(`Successfully updated application status to ${status}`);
  
  return result;
};

module.exports = {
  createApplication,
  getAllApplications,
  getApplicationsByStudent,
  getApplicationsByInternship,
  getApplicationsByCompany,
  updateApplicationStatus
};
