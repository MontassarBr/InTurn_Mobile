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

module.exports = {
  applyToInternshipHandler,
  getStudentApplicationsHandler,
  getInternshipApplicationsHandler,
  updateApplicationStatusHandler
};
