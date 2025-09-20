const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { 
  getProfile, 
  updateProfile, 
  addEducation, 
  addSkill, 
  addProExperience, 
  getFullProfileHandler 
} = require('../controllers/studentController');

router.use(protect);

router.get('/me', getProfile);
router.put('/me', updateProfile);

router.post('/education', addEducation);
router.post('/skills', addSkill);
router.post('/experience', addProExperience);

router.get('/full', getFullProfileHandler);

module.exports = router;
