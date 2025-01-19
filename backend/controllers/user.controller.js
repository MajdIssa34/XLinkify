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
        const { id } = req.params; // ID of the user to be added/removed from the watchlist
        const currentUserId = req.user._id; // ID of the current logged-in user

        if (id === currentUserId.toString()) {
            return res.status(400).json({ error: "You can't add yourself to the watchlist" });
        }

        // Find both the current user and the user to add to the watchlist
        const currentUser = await User.findById(currentUserId);
        const userToModify = await User.findById(id);

        if (!currentUser || !userToModify) {
            return res.status(404).json({ error: "User not found" });
        }

        // Check if the user is already in the watchlist
        const isInWatchlist = currentUser.watchlist.includes(id);

        if (isInWatchlist) {
            // Remove from the watchlist
            await User.findByIdAndUpdate(currentUserId, { $pull: { watchlist: id } });
            res.status(200).json({ message: "Removed from watchlist" });
        } else {
            // Add to the watchlist
            await User.findByIdAndUpdate(currentUserId, { $push: { watchlist: id } });

            // Create a notification for the user being added to the watchlist
            const newNotification = new Notification({
                type: "watchlist",
                from: currentUserId,
                to: userToModify._id,
                description: `${currentUser.username} added you to their watchlist.`,
            });

            await newNotification.save();

            res.status(200).json({ message: "Added to watchlist" });
        }
    } catch (error) {
        console.error("Error in addToWatchlist controller:", error.message);
        res.status(500).json({ message: "Internal server error" });
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


// export const followUnfollowUser = async (req, res) => {
//     try {
//         const { id } = req.params;
//         const userToModify = await User.findById(id);
//         const currentUser = await User.findById(req.user._id);

//         if (id === req.user._id.toString()) {
//             return res.status(400).json({ error: "You can't follow/unfollow yourself" });
//         }

//         if (!userToModify || !currentUser) {
//             return res.status(400).json({ error: "User not found" });
//         }

//         const isFollowing = currentUser.following.includes(id);

//         if (isFollowing) {
//             // unfollow
//             await User.findByIdAndUpdate(id, { $pull: { followers: req.user._id } });
//             await User.findByIdAndUpdate(req.user._id, { $pull: { following: id } });
//             res.status(200).json({ message: "Unfollowed successfully" });
//         } else {
//             // follow
//             await User.findByIdAndUpdate(id, { $push: { followers: req.user._id } });
//             await User.findByIdAndUpdate(req.user._id, { $push: { following: id } });

//             const newNotification = new Notification({
//                 type: 'follow',
//                 from: req.user._id,
//                 to: userToModify._id,
//             });

//             await newNotification.save();

//             // TODO:
//             res.status(200).json({ message: "Followed successfully" });

//         }
//     } catch (error) {
//         res.status(500).json({ message: "Internal server error" });
//         console.log("Error in getUserProfile controller:", error.message);
//     }
// };

// export const getSuggestedUsers = async (req, res) => {
//     try {
//         const userId = req.user._id;

//         const usersFollowedByMe = await User.findById(userId).select("following");

//         const users = await User.aggregate([
//             {
//                 $match: {
//                     _id: { $ne: userId }
//                 }
//             },
//             {
//                 $sample: { size: 10 }
//             }
//         ]);

//         const filteredUsers = users.filter(user => !usersFollowedByMe.following.includes(user._id));
//         const suggestedUsers = filteredUsers.slice(0, 6);

//         suggestedUsers.forEach(user => {
//             user.password = null;
//         });
//         res.status(200).json(suggestedUsers);
//     } catch (error) {

//     }
// };

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

// export const getUserById = async (req, res) => {
//     try {
//         const { id } = req.params;
//         const user = await User.findById(id, 'username profileImg'); // Select only username and profileImg

//         if (!user) {
//             return res.status(404).json({ message: 'User not found' });
//         }

//         res.status(200).json({
//             username: user.username,
//             profileImg: user.profileImg,
//         });
//     } catch (error) {
//         console.error('Error fetching user details:', error);
//         res.status(500).json({ message: 'Server error' });
//     }

// };

// export const getUserFollowersFollowing = async (req, res) => {
//     try {
//         const userId = req.user._id; // Get current user ID

//         // Find the user and populate both followers and following fields
//         const user = await User.findById(userId)
//             .select('followers following') // Select only followers and following fields
//             .populate({
//                 path: 'followers',
//                 select: 'username profileImg', // Fetch username and profileImg for followers
//             })
//             .populate({
//                 path: 'following',
//                 select: 'username profileImg', // Fetch username and profileImg for following
//             });

//         if (!user) {
//             return res.status(404).json({ message: 'User not found' });
//         }

//         // Respond with both followers and following
//         res.status(200).json({
//             followers: user.followers,
//             following: user.following,
//         });
//     } catch (error) {
//         console.error('Error fetching followers and following:', error);
//         res.status(500).json({ message: 'Server error' });
//     }
// };

