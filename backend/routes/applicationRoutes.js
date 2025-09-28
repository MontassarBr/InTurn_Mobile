const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');

const {
  applyToInternshipHandler,
  getStudentApplicationsHandler,
  getInternshipApplicationsHandler,
  getCompanyApplicationsHandler,
  getCompanyApplicationsPublicHandler,
  updateApplicationStatusHandler,
  updateApplicationStatusPublicHandler
} = require('../controllers/applicationController');

//Students
// Apply to internship
router.post('/', protect, applyToInternshipHandler);

// Get all applications for the logged-in student
router.get('/student', protect, getStudentApplicationsHandler);

//Companies
// Get all applications for a specific internship
router.get('/internship/:internshipID', protect, getInternshipApplicationsHandler);

// Get all applications for all company's internships
router.get('/company/:companyID', protect, getCompanyApplicationsHandler);

// Public endpoint for testing (no auth required)
router.get('/public/company/:companyID', getCompanyApplicationsPublicHandler);

// Update application status (company only)
router.put('/status', protect, updateApplicationStatusHandler);

// Public endpoint for status update (testing only)
router.put('/public/status', updateApplicationStatusPublicHandler);

module.exports = router;
