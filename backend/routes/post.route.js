import express from 'express';
import { createPost, deletePost, commentOnPost, likeUnlikePost, getAllPosts, getUserPosts, getWatchlistPosts } from '../controllers/post.controller.js';
import { protectRoute} from '../middleware/protectRoute.js';

const router = express.Router();

router.get('/all', protectRoute, getAllPosts);
router.get('/user/:username', protectRoute, getUserPosts);
router.post('/create', protectRoute, createPost);
router.delete('/:id', protectRoute, deletePost);
router.post('/comment/:id', protectRoute, commentOnPost);
router.post('/like/:id', protectRoute, likeUnlikePost);
router.get('/watchlist', protectRoute, getWatchlistPosts)

export default router;