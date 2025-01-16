import User from "../models/user.model.js";
import jwt from "jsonwebtoken";


export const protectRoute = async (req, res, next) => {
    try {
        const authHeader = req.headers.authorization;

        // Debugging: Log the Authorization header
        console.log("Authorization Header:", authHeader);

        if (!authHeader || !authHeader.startsWith("Bearer ")) {
            return res.status(401).json({ message: "Unauthorized: No token provided" });
        }

        const token = authHeader.split(" ")[1]; // Extract token

        // Debugging: Log the extracted token
        console.log("Extracted Token:", token);

        const decoded = jwt.verify(token, process.env.JWT_SECRET);

        if (!decoded) {
            return res.status(401).json({ message: "Unauthorized: Invalid token" });
        }

        const user = await User.findById(decoded.userId).select("-password");

        if (!user) {
            return res.status(404).json({ message: "User not found" });
        }

        req.user = user;
        next();
    } catch (error) {
        console.log("Error in protectRoute middleware:", error.message);
        return res.status(500).json({ message: "Internal server error" });
    }
};
