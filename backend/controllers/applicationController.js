const Application = require('../models/applicationModel');
const Internship = require('../models/internshipModel');

// Apply to internship (students only)
const applyToInternshipHandler = async (req, res) => {
  try {
    if (req.user.userType !== 'Student') {
      return res.status(403).json({ message: "Only students can apply to internships" });
    }

    const { internshipID } = req.body;
    if (!internshipID) return res.status(400).json({ message: "internshipID is required" });

    // Check if internship exists
    const internship = await Internship.getInternshipById(internshipID);
    if (!internship) return res.status(404).json({ message: "Internship not found" });

    const result = await Application.createApplication(req.user.userID, internshipID);
    res.status(201).json({ message: "Application submitted", applicationID: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Get all applications for a student
const getStudentApplicationsHandler = async (req, res) => {
  try {
    if (req.user.userType !== 'Student') {
      return res.status(403).json({ message: "Only students can view their applications" });
    }

    const applications = await Application.getApplicationsByStudent(req.user.userID);
    res.json(applications);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Get all applications for a company's internship
const getInternshipApplicationsHandler = async (req, res) => {
  try {
    if (req.user.userType !== 'Company') {
      return res.status(403).json({ message: "Only companies can view applications" });
    }

    const { internshipID } = req.params;
    const internship = await Internship.getInternshipById(internshipID);
    if (!internship || internship.companyID !== req.user.userID) {
      return res.status(403).json({ message: "You can only view applications for your own internships" });
    }

    const applications = await Application.getApplicationsByInternship(internshipID);
    res.json(applications);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Get all applications for all company's internships
const getCompanyApplicationsHandler = async (req, res) => {
  try {
    if (req.user.userType !== 'Company') {
      return res.status(403).json({ message: "Only companies can view applications" });
    }

    const { companyID } = req.params;
    if (parseInt(companyID) !== req.user.userID) {
      return res.status(403).json({ message: "You can only view your own applications" });
    }

    const applications = await Application.getApplicationsByCompany(companyID);
    res.json(applications);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Update application status (company only)
const updateApplicationStatusHandler = async (req, res) => {
  try {
    if (req.user.userType !== 'Company') {
      return res.status(403).json({ message: "Only companies can update application status" });
    }

    const { studentID, internshipID, applicationDate, status } = req.body;
    if (!studentID || !internshipID || !applicationDate || !status) {
      return res.status(400).json({ message: "All fields are required" });
    }

    // Check ownership
    const internship = await Internship.getInternshipById(internshipID);
    if (!internship || internship.companyID !== req.user.userID) {
      return res.status(403).json({ message: "You can only update applications for your own internships" });
    }

    await Application.updateApplicationStatus(studentID, internshipID, applicationDate, status);
    res.json({ message: "Application status updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Public endpoint for testing (no auth required)
const getCompanyApplicationsPublicHandler = async (req, res) => {
  try {
    console.log('Public API called for company applications');
    const { companyID } = req.params;
    
    if (!companyID) {
      return res.status(400).json({ message: "Company ID is required" });
    }

    // Debug: Check what data exists
    console.log(`\n=== DEBUG INFO FOR COMPANY ${companyID} ===`);
    
    // Check if company exists
    const pool = require('../config/db');
    const [companyCheck] = await pool.query('SELECT * FROM Company WHERE companyID = ?', [companyID]);
    console.log(`Company exists:`, companyCheck.length > 0 ? 'YES' : 'NO', companyCheck);
    
    // Check internships for this company
    const [internshipCheck] = await pool.query('SELECT * FROM Internship WHERE companyID = ?', [companyID]);
    console.log(`Internships for company ${companyID}:`, internshipCheck.length, 'found');
    console.log(internshipCheck);
    
    // Check all applications
    const [allApplications] = await pool.query('SELECT * FROM Application');
    console.log(`Total applications in database:`, allApplications.length);
    console.log(allApplications);
    
    // Check applications for this company's internships
    const [companyApps] = await pool.query(`
      SELECT a.*, i.title, i.companyID 
      FROM Application a 
      JOIN Internship i ON a.internshipID = i.internshipID 
      WHERE i.companyID = ?
    `, [companyID]);
    console.log(`Applications for company ${companyID}:`, companyApps.length, 'found');
    console.log(companyApps);
    
    // Check the actual column type of applicationDate
    const [columnInfo] = await pool.query(`
      SELECT COLUMN_NAME, DATA_TYPE, COLUMN_TYPE 
      FROM INFORMATION_SCHEMA.COLUMNS 
      WHERE TABLE_NAME = 'Application' AND COLUMN_NAME = 'applicationDate'
    `);
    console.log(`ApplicationDate column info:`, columnInfo);
    
    console.log(`=== END DEBUG INFO ===\n`);

    const applications = await Application.getApplicationsByCompany(parseInt(companyID));
    console.log(`Found ${applications.length} applications for company ${companyID}`);
    res.json(applications);
  } catch (err) {
    console.error('Error in getCompanyApplicationsPublicHandler:', err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Public endpoint for updating status (testing only - no auth required)
const updateApplicationStatusPublicHandler = async (req, res) => {
  try {
    console.log('Public status update called');
    const { studentID, internshipID, applicationDate, status } = req.body;
    
    if (!studentID || !internshipID || !applicationDate || !status) {
      return res.status(400).json({ message: "All fields are required" });
    }

    console.log(`Updating application status: studentID=${studentID}, internshipID=${internshipID}, applicationDate=${applicationDate}, status=${status}`);
    
    await Application.updateApplicationStatus(studentID, internshipID, applicationDate, status);
    res.json({ message: "Application status updated successfully" });
  } catch (err) {
    console.error('Error in updateApplicationStatusPublicHandler:', err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

module.exports = {
  applyToInternshipHandler,
  getStudentApplicationsHandler,
  getInternshipApplicationsHandler,
  getCompanyApplicationsHandler,
  getCompanyApplicationsPublicHandler,
  updateApplicationStatusHandler,
  updateApplicationStatusPublicHandler // Add public status update endpoint
};
