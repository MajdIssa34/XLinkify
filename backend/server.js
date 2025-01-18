import express from "express";
import authRoutes from "./routes/auth.route.js";
import userRoutes from "./routes/user.route.js";
import postRoutes from "./routes/post.route.js";
import notficationRoutes from "./routes/notification.route.js";
import cors from "cors"; // Keep this import (ES Modules)

import { v2 as cloudinary } from "cloudinary";
import dotenv from "dotenv";
import connectMongoDB from "./db/connectMongoDB.js";
import cookieParser from "cookie-parser";

dotenv.config();

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
});

const app = express();

const PORT = process.env.PORT || 5000;
app.use(
    cors({
        origin: function (origin, callback) {
            // Allow requests with no origin (like mobile apps or Postman)
            if (!origin || allowedOrigins.includes(origin)) {
                callback(null, true); // Allow the request
            } else {
                callback(new Error("Not allowed by CORS")); // Reject the request
            }
        },
        credentials: true, // Allow cookies and authorization headers
    })
);

app.use(express.json({ limit: "10mb" })); // Adjust the size limit
app.use(express.urlencoded({ extended: true, limit: "10mb" }));

app.use(cookieParser());

// Configure CORS
const allowedOrigins = [
    "http://localhost:56954",
    "http://localhost:60152"
];

app.use("/api/auth", authRoutes);
app.use("/api/users", userRoutes);
app.use("/api/posts", postRoutes);
app.use("/api/notifications", notficationRoutes);

app.listen(8000, () => {
    console.log("Server is running on port", PORT);
    connectMongoDB();
});
