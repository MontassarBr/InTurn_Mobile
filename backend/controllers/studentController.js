const Student = require('../models/studentModel');

// Get basic student profile
const getProfile = async (req, res) => {
  try {
    if (req.user.userType !== 'Student') 
      return res.status(403).json({ message: "Only students can view this" });

    const student = await Student.getStudentById(req.user.userID);
    if (!student) return res.status(404).json({ message: "Student not found" });

    res.json(student);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Update student profile
const updateProfile = async (req, res) => {
  try {
    if (req.user.userType !== 'Student') 
      return res.status(403).json({ message: "Only students can update profile" });

    await Student.updateStudent(req.user.userID, req.body);
    res.json({ message: "Profile updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Add education
const addEducation = async (req, res) => {
  try {
    if (req.user.userType !== 'Student') 
      return res.status(403).json({ message: "Only students can add education" });

    await Student.addEducation(req.user.userID, req.body);
    res.json({ message: "Education added" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Add skill
const addSkill = async (req, res) => {
  try {
    if (req.user.userType !== 'Student') 
      return res.status(403).json({ message: "Only students can add skill" });

    await Student.addSkill(req.user.userID, req.body.skill);
    res.json({ message: "Skill added" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Add professional experience
const addProExperience = async (req, res) => {
  try {
    if (req.user.userType !== 'Student') 
      return res.status(403).json({ message: "Only students can add experience" });

    await Student.addProExperience(req.user.userID, req.body);
    res.json({ message: "Professional experience added" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Get full student profile
const getFullProfileHandler = async (req, res) => {
  try {
    if (req.user.userType !== 'Student') 
      return res.status(403).json({ message: "Only students can view this" });

    const profile = await Student.getFullProfile(req.user.userID);
    if (!profile) return res.status(404).json({ message: "Student not found" });

    res.json(profile);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = { 
  getProfile, 
  updateProfile, 
  addEducation, 
  addSkill, 
  addProExperience,
  getFullProfileHandler
};
