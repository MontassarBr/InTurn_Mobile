// controllers/internshipController.js
const Internship = require('../models/internshipModel');

// Create internship (only Company)
const createInternship = async (req, res) => {
  try {
    if (req.user.userType !== 'Company') {
      return res.status(403).json({ message: "Only companies can create internships" });
    }

    const { title, startDate, endDate, minSalary, maxSalary, description, location, payment, workArrangement, workTime } = req.body;

    if (!title || !startDate || !endDate || !location) {
      return res.status(400).json({ message: "Title, startDate, endDate, and location are required" });
    }

    const result = await Internship.createInternship(req.user.id, title, startDate, endDate, minSalary, maxSalary, description, location, payment, workArrangement, workTime, 'Published');
    res.status(201).json({ message: "Internship created", internshipID: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Get all internships
const getAllInternships = async (req, res) => {
  try {
    const internships = await Internship.getAllInternships();
    res.json(internships);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Get internship by ID
const getInternshipById = async (req, res) => {
  try {
    const { id } = req.params;
    const internship = await Internship.getInternshipById(id);
    if (internship.length === 0) return res.status(404).json({ message: "Internship not found" });
    res.json(internship[0]);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Update internship (only company who owns it)
const updateInternship = async (req, res) => {
  try {
    const { id } = req.params;
    const internship = await Internship.getInternshipById(id);
    if (internship.length === 0) return res.status(404).json({ message: "Internship not found" });

    if (req.user.userType !== 'Company' || internship[0].companyID !== req.user.id) {
      return res.status(403).json({ message: "You can only update your own internships" });
    }

    const result = await Internship.updateInternship(id, req.body);
    res.json({ message: "Internship updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Delete internship (only company who owns it)
const deleteInternship = async (req, res) => {
  try {
    const { id } = req.params;
    const internship = await Internship.getInternshipById(id);
    if (internship.length === 0) return res.status(404).json({ message: "Internship not found" });

    if (req.user.userType !== 'Company' || internship[0].companyID !== req.user.id) {
      return res.status(403).json({ message: "You can only delete your own internships" });
    }

    await Internship.deleteInternship(id);
    res.json({ message: "Internship deleted" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = { createInternship, getAllInternships, getInternshipById, updateInternship, deleteInternship };
