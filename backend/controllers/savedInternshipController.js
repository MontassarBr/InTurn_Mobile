const SavedInternship = require('../models/savedInternshipModel');

// Get all saved internships for a student
const getSavedInternshipsHandler = async (req, res) => {
  try {
    if (req.user.userType !== 'Student') {
      return res.status(403).json({ message: "Only students can view saved internships" });
    }

    const savedInternships = await SavedInternship.getSavedInternships(req.user.userID);
    
    // Transform the data to match frontend expectations
    const transformedData = savedInternships.map(item => ({
      studentID: item.studentID,
      internshipID: item.internshipID,
      savedDate: item.savedDate,
      internship: {
        internshipID: item.internshipID,
        companyID: item.companyID,
        title: item.title,
        startDate: item.startDate,
        endDate: item.endDate,
        minSalary: item.minSalary,
        maxSalary: item.maxSalary,
        description: item.description,
        location: item.location,
        payment: item.payment,
        workArrangement: item.workArrangement,
        workTime: item.workTime,
        status: item.status,
        companyName: item.companyName,
        industry: item.industry
      }
    }));

    res.json(transformedData);
  } catch (err) {
    console.error('Error in getSavedInternshipsHandler:', err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Save an internship
const saveInternshipHandler = async (req, res) => {
  try {
    if (req.user.userType !== 'Student') {
      return res.status(403).json({ message: "Only students can save internships" });
    }

    const { internshipID } = req.body;

    if (!internshipID) {
      return res.status(400).json({ message: "Internship ID is required" });
    }

    // Check if internship is already saved
    const isAlreadySaved = await SavedInternship.isInternshipSaved(req.user.userID, internshipID);
    if (isAlreadySaved) {
      return res.status(409).json({ message: "Internship is already saved" });
    }

    const result = await SavedInternship.saveInternship(req.user.userID, internshipID);
    
    if (result.affectedRows > 0) {
      res.status(201).json({ 
        message: "Internship saved successfully",
        studentID: req.user.userID,
        internshipID: internshipID
      });
    } else {
      res.status(400).json({ message: "Failed to save internship" });
    }
  } catch (err) {
    console.error('Error in saveInternshipHandler:', err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Unsave an internship
const unsaveInternshipHandler = async (req, res) => {
  try {
    if (req.user.userType !== 'Student') {
      return res.status(403).json({ message: "Only students can unsave internships" });
    }

    const { internshipID } = req.params;

    if (!internshipID) {
      return res.status(400).json({ message: "Internship ID is required" });
    }

    const result = await SavedInternship.unsaveInternship(req.user.userID, internshipID);
    
    if (result.affectedRows > 0) {
      res.json({ 
        message: "Internship removed from saved list",
        studentID: req.user.userID,
        internshipID: internshipID
      });
    } else {
      res.status(404).json({ message: "Saved internship not found" });
    }
  } catch (err) {
    console.error('Error in unsaveInternshipHandler:', err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Check if an internship is saved
const checkSavedStatusHandler = async (req, res) => {
  try {
    if (req.user.userType !== 'Student') {
      return res.status(403).json({ message: "Only students can check saved status" });
    }

    const { internshipID } = req.params;
    const isSaved = await SavedInternship.isInternshipSaved(req.user.userID, internshipID);
    
    res.json({ 
      internshipID: internshipID,
      isSaved: isSaved
    });
  } catch (err) {
    console.error('Error in checkSavedStatusHandler:', err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

// Get count of saved internships
const getSavedCountHandler = async (req, res) => {
  try {
    if (req.user.userType !== 'Student') {
      return res.status(403).json({ message: "Only students can view saved count" });
    }

    const count = await SavedInternship.getSavedCount(req.user.userID);
    res.json({ count: count });
  } catch (err) {
    console.error('Error in getSavedCountHandler:', err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

module.exports = {
  getSavedInternshipsHandler,
  saveInternshipHandler,
  unsaveInternshipHandler,
  checkSavedStatusHandler,
  getSavedCountHandler
};
