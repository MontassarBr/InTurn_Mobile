// routes/internshipRoutes.js
const express = require('express');
const router = express.Router();
const {
  createInternshipHandler,
  getInternshipsHandler,
  getInternshipByIdHandler,
  updateInternshipHandler,
  deleteInternshipHandler
} = require('../controllers/internshipController');
const { protect } = require('../middleware/authMiddleware');

// Public routes for students
router.get('/', getInternshipsHandler);       
router.get('/:id', getInternshipByIdHandler); 

// Protected routes for companies
router.post('/', protect, createInternshipHandler);
router.put('/:id', protect, updateInternshipHandler);
router.delete('/:id', protect, deleteInternshipHandler);

module.exports = router;
