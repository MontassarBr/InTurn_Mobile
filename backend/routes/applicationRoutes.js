const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');

const {
  applyToInternshipHandler,
  getStudentApplicationsHandler,
  getInternshipApplicationsHandler,
  updateApplicationStatusHandler
} = require('../controllers/applicationController');

//Students
// Apply to internship
router.post('/', protect, applyToInternshipHandler);

// Get all applications for the logged-in student
router.get('/student', protect, getStudentApplicationsHandler);

//Companies
// Get all applications for a specific internship
router.get('/internship/:internshipID', protect, getInternshipApplicationsHandler);

// Update application status (company only)
router.put('/status', protect, updateApplicationStatusHandler);

module.exports = router;
