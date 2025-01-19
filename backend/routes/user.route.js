import express from "express";
import { protectRoute } from "../middleware/protectRoute.js";
import { getUserProfile, updateUser, addToWatchlist, getUserWatchlist} from "../controllers/user.controller.js";

const router = express.Router();

router.get("/profile/:username",protectRoute, getUserProfile);
//router.get("/suggested", protectRoute, getSuggestedUsers);
//router.post("/follow/:id", protectRoute, followUnfollowUser);
router.post("/update", protectRoute, updateUser);
// router.get("/username/:id", protectRoute, getUserById);
router.put('/watchlist/:id', protectRoute, addToWatchlist)
//router.get("/username/", protectRoute, getUserFollowersFollowing);
router.get("/watchlist/:username",protectRoute, getUserWatchlist);

export default router;
