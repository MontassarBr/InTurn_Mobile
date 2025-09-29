const express = require('express');
const {
  getSavedInternshipsHandler,
  saveInternshipHandler,
  unsaveInternshipHandler,
  checkSavedStatusHandler,
  getSavedCountHandler
} = require('../controllers/savedInternshipController');
const { protect } = require('../middleware/authMiddleware');

const router = express.Router();

// All routes require authentication since only students can save internships
router.use(protect);

// GET /api/saved-internships - Get all saved internships for current student
router.get('/', getSavedInternshipsHandler);

// POST /api/saved-internships - Save an internship
router.post('/', saveInternshipHandler);

// GET /api/saved-internships/count - Get count of saved internships
router.get('/count', getSavedCountHandler);

// GET /api/saved-internships/check/:internshipID - Check if internship is saved
router.get('/check/:internshipID', checkSavedStatusHandler);

// DELETE /api/saved-internships/:internshipID - Remove internship from saved list
router.delete('/:internshipID', unsaveInternshipHandler);

module.exports = router;
