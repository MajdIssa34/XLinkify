import bcrypt from "bcryptjs";
import { v2 as cloudinary } from "cloudinary";

import User from "../models/user.model.js";
import Notification from "../models/notification.model.js";

export const getUserProfile = async (req, res) => {
    const { username } = req.params;

    try {
        const user = await User.findOne({ username }).select("-password");

        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }
        res.status(200).json(user);
    } catch (error) {
        res.status(500).json({ message: "Internal server error" });
        console.log("Error in getUserProfile controller:", error.message);
    }
};

export const addToWatchlist = async (req, res) => {
    try {
        const { id } = req.params; // ID of the user to be added/removed
        const currentUserId = req.user._id; // ID of the logged-in user

        if (id === currentUserId.toString()) {
            return res.status(400).json({ error: "You can't add yourself to the watchlist" });
        }

        // Find the current user
        const currentUser = await User.findById(currentUserId);

        if (!currentUser) {
            return res.status(404).json({ error: "Current user not found" });
        }

        // Check if the user exists
        const userToModify = await User.findById(id);
        if (!userToModify) {
            return res.status(404).json({ error: "User to modify not found" });
        }

        const isInWatchlist = currentUser.watchlist.includes(id);

        if (isInWatchlist) {
            // Remove from the watchlist
            await User.findByIdAndUpdate(currentUserId, { $pull: { watchlist: id } }, { new: true });
            const updatedUser = await User.findById(currentUserId).select('watchlist');
            const updatedCount = updatedUser.watchlist.length; // Get the new count after update

            return res.status(200).json({
                message: "Removed from watchlist",
                action: "removed",
                updatedCount,
            });
        } else {
            // Add to the watchlist
            await User.findByIdAndUpdate(currentUserId, { $push: { watchlist: id } }, { new: true });
            const updatedUser = await User.findById(currentUserId).select('watchlist');
            const updatedCount = updatedUser.watchlist.length; // Get the new count after update

            // Create a notification
            const notification = new Notification({
                to: id,
                from: currentUserId,
                type: 'watchlist',
                description: `${currentUser.username} added you to their watchlist.`,
                createdAt: new Date(),
            });
            await notification.save();

            return res.status(200).json({
                message: "Added to watchlist",
                action: "added",
                updatedCount,
            });
        }
    } catch (error) {
        console.error("Error in addToWatchlist controller:", error.message);
        return res.status(500).json({ error: "Internal server error" });
    }
};




export const getUserWatchlist = async (req, res) => {
    const { username } = req.params;

    try {
        const user = await User.findOne({ username }).populate({
            path: "watchlist",
            select: "username fullName profileImg",
        });

        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

        res.status(200).json(user.watchlist);
    } catch (error) {
        res.status(500).json({ message: "Internal server error" });
        console.error("Error in getUserWatchlist controller:", error.message);
    }
};

export const searchUsers = async (req, res) => {
    try {
      const { query } = req.query; // Search query from the frontend
      if (!query) {
        return res.status(400).json({ error: 'Query parameter is required' });
      }
  
      const users = await User.find({
        $or: [
          { username: { $regex: query, $options: 'i' } }, // Match username
          { fullName: { $regex: query, $options: 'i' } }, // Match full name
        ],
      }).select('username fullName profileImg bio link'); // Limit fields for performance
  
      res.status(200).json({ users });
    } catch (error) {
      console.error('Error in searchUsers:', error.message);
      res.status(500).json({ error: 'Internal server error' });
    }
  };
  
export const updateUser = async (req, res) => {
    const { fullName, username, email, currentPassword, newPassword, bio, link } = req.body;
    let { profileImg, coverImg } = req.body;

    const userId = req.user._id;

    try {
        let user = await User.findById(userId);
        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }
        if (!newPassword && currentPassword) {
            return res.status(400).json({ error: "Please provide new and current password" });
        }
        if (currentPassword && newPassword) {
            const isMatch = await bcrypt.compare(currentPassword, user.password);
            if (!isMatch) {
                return res.status(400).json({ error: "Current password is incorrect" });
            }
            if (newPassword.length < 6) {
                return res.status(400).json({ error: "Password must be at least 6 characters long" });
            }
            const salt = await bcrypt.genSalt(10);
            user.password = await bcrypt.hash(newPassword, salt);
        }
        if (profileImg) {
            try {
                if (user.profileImg) {
                    await cloudinary.uploader.destroy(user.profileImg.split("/").pop().split(".")[0]);
                }
                const uploadedResponse = await cloudinary.uploader.upload(`data:image/jpeg;base64,${profileImg}`);
                profileImg = uploadedResponse.secure_url;
            } catch (err) {
                console.error("Error uploading profile image:", err);
                return res.status(500).json({ message: "Error uploading profile image" });
            }
        }

        if (coverImg) {
            if (user.coverImg) {
                await cloudinary.uploader.destroy(user.coverImg.split("/").pop().split(".")[0]);
            }
            const uploadedResponse = await cloudinary.uploader.upload(coverImg);
            coverImg = uploadedResponse.secure_url;
        }

        user.fullName = fullName || user.fullName;
        user.email = email || user.email;
        user.username = username || user.username;
        user.bio = bio || user.bio;
        user.link = link || user.link;
        user.profileImg = profileImg || user.profileImg;
        user.coverImg = coverImg || user.coverImg;

        await user.save();

        user.password = null;

        return res.status(200).json({ user });

    } catch (error) {
        res.status(500).json({ message: "Internal server error" });
        console.log("Error in updateUser controller:", error.message);
    }
};