const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { getProfile, updateProfile, addBenefit } = require('../controllers/companyController');

router.use(protect);

router.get('/me', getProfile);
router.put('/me', updateProfile);
router.post('/benefits', addBenefit);
router.get('/full', getFullProfileHandler);
module.exports = router;
