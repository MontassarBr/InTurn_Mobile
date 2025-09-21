const jwt = require('jsonwebtoken');
const pool = require('../config/db');

const protect = async (req, res, next) => {
  let token;

  if (req.headers.authorization && req.headers.authorization.startsWith('Bearer')) {
    try {
      token = req.headers.authorization.split(' ')[1];
      const decoded = jwt.verify(token, process.env.JWT_SECRET);

      // Fetch user from User table using userID
      const [rows] = await pool.query(
        "SELECT userID, email, userType, location, description, profilePic FROM User WHERE userID = ?",
        [decoded.id]
      );

      if (rows.length === 0) {
        return res.status(401).json({ message: "User not found" });
      }

      // Attach user info to request
      req.user = {
        userID: rows[0].userID,
        email: rows[0].email,
        userType: rows[0].userType,
        location: rows[0].location,
        description: rows[0].description,
        profilePic: rows[0].profilePic,
      };

      next();
    } catch (err) {
      console.error(err);
      return res.status(401).json({ message: "Not authorized, token failed" });
    }
  } else {
    return res.status(401).json({ message: "Not authorized, no token" });
  }
};

module.exports = { protect };
