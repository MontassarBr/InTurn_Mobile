const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { getProfile, updateProfile, addBenefit, deleteBenefit, getFullProfileHandler, getAllCompaniesHandler } = require('../controllers/companyController');

// Public endpoint (no auth required)
router.get('/all', getAllCompaniesHandler);

// Protected endpoints
router.use(protect);

router.get('/me', getProfile);
router.put('/me', updateProfile);
router.post('/benefits', addBenefit);
router.delete('/benefits/:benefit', deleteBenefit);
router.get('/full', getFullProfileHandler);

module.exports = router;
