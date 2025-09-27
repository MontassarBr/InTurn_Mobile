const express = require('express');
const router = express.Router();
const { protect } = require('../middleware/authMiddleware');
const { 
  getProfile, 
  updateProfile, 
  addEducation, 
  addSkill,
  deleteSkill,
  addProExperience,
  deleteEducation,
  deleteProExperience,
  getFullProfileHandler 
} = require('../controllers/studentController');

router.use(protect);

router.get('/me', getProfile);
router.put('/me', updateProfile);

router.post('/education', addEducation);
router.delete('/education', deleteEducation);
router.post('/skills', addSkill);
router.delete('/skills/:skill', deleteSkill);
router.post('/experience', addProExperience);
router.delete('/experience/:id', deleteProExperience);

router.get('/full', getFullProfileHandler);

module.exports = router;
