const Company = require('../models/companyModel');

// Get basic company profile
const getProfile = async (req, res) => {
  try {
    if (req.user.userType !== 'Company') 
      return res.status(403).json({ message: "Only companies can view this" });

    const company = await Company.getCompanyById(req.user.userID);
    if (!company) return res.status(404).json({ message: "Company not found" });

    res.json(company);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Update company profile
const updateProfile = async (req, res) => {
  try {
    if (req.user.userType !== 'Company') 
      return res.status(403).json({ message: "Only companies can update profile" });

    await Company.updateCompany(req.user.userID, req.body);
    res.json({ message: "Profile updated" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Add company benefit
const addBenefit = async (req, res) => {
  try {
    if (req.user.userType !== 'Company') 
      return res.status(403).json({ message: "Only companies can add benefit" });

    await Company.addBenefit(req.user.userID, req.body.benefit);
    res.json({ message: "Benefit added" });
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

// Get full company profile
const getFullProfileHandler = async (req, res) => {
  try {
    if (req.user.userType !== 'Company') 
      return res.status(403).json({ message: "Only companies can view this" });

    const profile = await Company.getFullProfile(req.user.userID);
    if (!profile) return res.status(404).json({ message: "Company not found" });

    res.json(profile);
  } catch (err) {
    console.error(err);
    res.status(500).json({ message: "Server error" });
  }
};

module.exports = { getProfile, updateProfile, addBenefit, getFullProfileHandler };
