const Internship = require('../models/internshipModel');

// Company creates a new internship
const createInternshipHandler = async (req, res) => {
  try {
    if (req.user.userType !== 'Company') {
      return res.status(403).json({ message: "Only companies can create internships" });
    }

    const { title, startDate, endDate, minSalary, maxSalary, description, location, payment, workArrangement, workTime } = req.body;

    if (!title || !startDate || !endDate || !location) {
      return res.status(400).json({ message: "Title, startDate, endDate, and location are required" });
    }

    const result = await Internship.createInternship(
      req.user.userID, title, startDate, endDate, minSalary, maxSalary, description,
      location, payment, workArrangement, workTime, 'Published'
    );

    res.status(201).json({ message: "Internship created", internshipID: result.insertId });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Get internships (students) with optional filters and pagination
const getInternshipsHandler = async (req, res) => {
  try {
    // Extract filters from query params
    const filters = {
      location: req.query.location,
      workTime: req.query.workTime,
      workArrangement: req.query.workArrangement,
      payment: req.query.payment,
      limit: req.query.limit,
      offset: req.query.offset
    };

    const internships = await Internship.getInternships(filters);
    res.json(internships);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Get internship details by ID
const getInternshipByIdHandler = async (req, res) => {
  try {
    const { id } = req.params;
    const internship = await Internship.getInternshipById(id);

    if (!internship) return res.status(404).json({ message: "Internship not found" });

    res.json(internship);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Company updates internship
const updateInternshipHandler = async (req, res) => {
  try {
    const { id } = req.params;
    const internship = await Internship.getInternshipById(id);

    if (!internship) return res.status(404).json({ message: "Internship not found" });
    if (req.user.userType !== 'Company' || internship.companyID !== req.user.userID) {
      return res.status(403).json({ message: "You can only update your own internships" });
    }

    await Internship.updateInternship(id, req.body);
    res.json({ message: "Internship updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Company deletes internship
const deleteInternshipHandler = async (req, res) => {
  try {
    const { id } = req.params;
    console.log(`Delete request for internship ID: ${id} by user: ${req.user.userID}`);
    
    const internship = await Internship.getInternshipById(id);

    if (!internship) {
      console.log(`Internship not found: ${id}`);
      return res.status(404).json({ message: "Internship not found" });
    }
    
    if (req.user.userType !== 'Company' || internship.companyID !== req.user.userID) {
      console.log(`Authorization failed: userType=${req.user.userType}, companyID=${internship.companyID}, userID=${req.user.userID}`);
      return res.status(403).json({ message: "You can only delete your own internships" });
    }

    console.log(`Deleting internship: ${internship.title}`);
    const result = await Internship.deleteInternship(id);
    console.log(`Delete result:`, result);
    
    res.json({ message: "Internship deleted successfully" });
  } catch (err) {
    console.error('Error in deleteInternshipHandler:', err);
    res.status(500).json({ message: "Server error", error: err.message });
  }
};

module.exports = { 
  createInternshipHandler, 
  getInternshipsHandler, 
  getInternshipByIdHandler, 
  updateInternshipHandler, 
  deleteInternshipHandler 
};
