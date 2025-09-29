const pool = require('../config/db');

class SavedInternship {
  // Get all saved internships for a student with full internship details
  static async getSavedInternships(studentID) {
    const query = `
      SELECT 
        si.studentID,
        si.internshipID,
        si.savedDate,
        i.companyID,
        i.title,
        i.startDate,
        i.endDate,
        i.minSalary,
        i.maxSalary,
        i.description,
        i.location,
        i.payment,
        i.workArrangement,
        i.workTime,
        i.status,
        c.companyName,
        c.industry
      FROM SavedInternship si
      JOIN Internship i ON si.internshipID = i.internshipID
      JOIN Company c ON i.companyID = c.companyID
      WHERE si.studentID = ?
      ORDER BY si.savedDate DESC
    `;
    
    const [rows] = await pool.query(query, [studentID]);
    return rows;
  }

  // Save an internship for a student
  static async saveInternship(studentID, internshipID) {
    const query = `
      INSERT IGNORE INTO SavedInternship (studentID, internshipID)
      VALUES (?, ?)
    `;
    
    const [result] = await pool.query(query, [studentID, internshipID]);
    return result;
  }

  // Remove a saved internship
  static async unsaveInternship(studentID, internshipID) {
    const query = `
      DELETE FROM SavedInternship 
      WHERE studentID = ? AND internshipID = ?
    `;
    
    const [result] = await pool.query(query, [studentID, internshipID]);
    return result;
  }

  // Check if an internship is saved by a student
  static async isInternshipSaved(studentID, internshipID) {
    const query = `
      SELECT 1 FROM SavedInternship 
      WHERE studentID = ? AND internshipID = ?
    `;
    
    const [rows] = await pool.query(query, [studentID, internshipID]);
    return rows.length > 0;
  }

  // Get count of saved internships for a student
  static async getSavedCount(studentID) {
    const query = `
      SELECT COUNT(*) as count FROM SavedInternship 
      WHERE studentID = ?
    `;
    
    const [rows] = await pool.query(query, [studentID]);
    return rows[0].count;
  }
}

module.exports = SavedInternship;
