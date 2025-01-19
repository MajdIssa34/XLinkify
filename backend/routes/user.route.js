import express from "express";
import { protectRoute } from "../middleware/protectRoute.js";
import { getUserProfile, updateUser, addToWatchlist, getUserWatchlist, searchUsers} from "../controllers/user.controller.js";

const router = express.Router();

router.get("/profile/:username",protectRoute, getUserProfile);
router.post("/update", protectRoute, updateUser);
router.put('/watchlist/:id', protectRoute, addToWatchlist)
router.get("/watchlist/:username",protectRoute, getUserWatchlist);

router.get("/search", protectRoute, searchUsers);


export default router;
