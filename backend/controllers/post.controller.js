import Post from "../models/post.model.js";
import User from "../models/user.model.js";
import Notification from "../models/notification.model.js";
import { v2 as cloudinary } from "cloudinary";

export const createPost = async (req, res) => {
    try {
        let { text, img } = req.body;

        if (!req.user) {
            return res.status(401).json({ error: "Unauthorized: User not authenticated" });
        }

        const userId = req.user._id.toString();

        // Validate user existence
        const user = await User.findById(userId);
        if (!user) {
            return res.status(400).json({ error: "User not found" });
        }

        // Validate text or image presence
        if (!text && !img) {
            return res.status(400).json({ error: "Text or image is required" });
        }
        let imageUrl;
        if (img && !img.startsWith("data:image")) {
            img = `data:image/png;base64,${img}`;
          }
        if (img) {
            try {
                let uploadedResponse = await cloudinary.uploader.upload(img);
                imageUrl = uploadedResponse.secure_url;
            } catch (cloudinaryError) {
                console.error("Cloudinary upload failed:", cloudinaryError.message);
                return res.status(500).json({ error: "Image upload failed" });
            }
        }

        const newPost = new Post({
            user: userId,
            text,
            img: imageUrl,
        });
        await newPost.save();

        res.status(201).json(newPost);
    } catch (error) {
        console.error("Error in createPost controller:", error.message);
        res.status(500).json({ error: error.message });
    }
};


export const deletePost = async (req, res) => {

    try {
        const post = await Post.findById(req.params.id);
        if (!post) {
            return res.status(404).json({ error: "Post not found" });
        }
        if (post.user.toString() !== req.user._id.toString()) {
            return res.status(401).json({ error: "You are not authorized to delete this post" });
        }

        if (post.img) {
            const imgId = post.img.split("/").pop().split(".")[0];
            await cloudinary.uploader.destroy(imgId);
        }

        await Post.findByIdAndDelete(req.params.id);

        res.status(200).json({ message: "Post deleted successfully" });
    } catch (error) {
        console.log("Error in deletePost controller:", error.message);
        res.status(500).json({ error: "Internal server error" });
    }
};

export const commentOnPost = async (req, res) => {
    try {
        const { text } = req.body;
        const postId = req.params.id;
        const userId = req.user._id;

        if (!text) {
            return res.status(400).json({ error: "Comment text is required" });
        }

        const post = await Post.findById(postId);

        if (!post) {
            return res.status(404).json({ error: "Post not found" });
        }

        const comment = {
            text,
            user: userId
        };

        post.comments.push(comment);
        await post.save();

        res.status(200).json(post);
    } catch (error) {
        console.log("Error in commentOnPost controller:", error.message);
        res.status(500).json({ error: "Internal server error" });
    }
};

export const likeUnlikePost = async (req, res) => {
    try {
        const userId = req.user._id;
        const { id: postId } = req.params;

        const post = await Post.findById(postId);

        if (!post) {
            return res.status(404).json({ error: "Post not found" });
        }

        const userLikedPost = post.likes.includes(userId);

        if (userLikedPost) {
            // unlike post
            await Post.updateOne({ _id: postId }, { $pull: { likes: userId } });
            res.status(200).json({ message: "Post unliked successfully" });
        } else {
            // like
            post.likes.push(userId);
            await post.save();

            const notification = new Notification({
                from: userId,
                to: post.user,
                type: "like",
            });

            await notification.save();

            res.status(200).json({ message: "Post liked successfully" });
        }
    } catch (error) {
        res.status(500).json({ error: "Internal server error" });
        console.log("Error in likeUnlikePost controller:", error.message);
    }
};

export const getAllPosts = async (req, res) => {

    try {
        const posts = await Post.find().sort({ createdAt: -1 }).populate({
            path: "user",
            select: "-password",
        })
            .populate({
                path: "comments.user",
                select: "-password",
            });

        if (posts.length === 0) {
            return res.status(200).json([]);
        }

        res.status(200).json(posts);
    } catch (error) {
        console.log("Error in getAllPosts controller:", error.message);
        res.status(500).json({ error: "Internal server error" });
    }
};

export const getFollowingPosts = async (req, res) => {

    try {
        const userId = req.user._id;
        const user = await User.findById(userId);

        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

        const following = user.following;

        const feedPost = await Post.find({ user: { $in: following } }).sort({ createdAt: -1 })
            .populate({
                path: "user",
                select: "-password",
            })
            .populate({
                path: "comments.user",
                select: "-password",
            });

        res.status(200).json(feedPost);
    } catch (error) {
        res.status(500).json({ error: "Internal server error" });
        console.log("Error in getFollowingPosts controller:", error.message);
    }
};

export const getUserPosts = async (req, res) => {
    try {
        const { username } = req.params;
        const user = await User.findOne({ username });

        if (!user) {
            return res.status(404).json({ error: "User not found" });
        }

        const posts = await Post.find({ user: user._id }).sort({ createdAt: -1 })
            .populate({
                path: "user",
                select: "-password",
            }).populate({
                path: "comments.user",
                select: "-password",
            });

        res.status(200).json(posts);
    } catch (error) {
        res.status(500).json({ error: "Internal server error" });
        console.log("Error in getUserPosts controller:", error.message);
    }
};