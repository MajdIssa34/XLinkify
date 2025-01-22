import express from "express";
import authRoutes from "./routes/auth.route.js";
import userRoutes from "./routes/user.route.js";
import postRoutes from "./routes/post.route.js";
import notficationRoutes from "./routes/notification.route.js";
import quoteRoutes from "./routes/quote.route.js";

import cors from "cors"; // Keep this import (ES Modules)
import { v2 as cloudinary } from "cloudinary";
import dotenv from "dotenv";
import connectMongoDB from "./db/connectMongoDB.js";
import cookieParser from "cookie-parser";

dotenv.config();

// Cloudinary Configuration
cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
});

const app = express();
const PORT = process.env.PORT || 5000;

// Allowed origins
const allowedOrigins = [
    "https://xlinkify.web.app", // Your frontend development server
    "https://xlinkify.onrender.com", // Add your production URL here
    "https://xlinkify.firebaseapp.com",
    "https://xlinkify.com"
];

// CORS Middleware
app.use(
    cors({
        origin: function (origin, callback) {
            // Allow requests from allowed origins or no origin (Postman, etc.)
            if (!origin || allowedOrigins.includes(origin)) {
                callback(null, true);
            } else {
                callback(new Error("Not allowed by CORS"));
            }
        },
        credentials: true, // Allow cookies and authorization headers
    })
);

// Handle Preflight Requests
app.options("*", cors());

// Middleware
app.use(express.json({ limit: "10mb" })); // Adjust the size limit
app.use(express.urlencoded({ extended: true, limit: "10mb" }));
app.use(cookieParser());

// Routes
app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/posts", postRoutes);
app.use("/api/notifications", notficationRoutes);
app.use("/api/quotes", quoteRoutes);

// Server Start
app.listen(PORT, () => {
    console.log("Server is running on port", PORT);
    connectMongoDB();
});
