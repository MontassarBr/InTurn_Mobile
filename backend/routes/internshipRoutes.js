// routes/internshipRoutes.js
const express = require('express');
const router = express.Router();
const { createInternship, getAllInternships, getInternshipById, updateInternship, deleteInternship } = require('../controllers/internshipController');
const { protect } = require('../middleware/authMiddleware'); 

router.get('/', getAllInternships);
router.get('/:id', getInternshipById);

router.post('/', protect, createInternship);
router.put('/:id', protect, updateInternship);
router.delete('/:id', protect, deleteInternship);

module.exports = router;
