import express from "express";
import { protectRoute } from "../middleware/protectRoute.js";
import { getQuote, addQuotes } from "../controllers/quote.controller.js";

const router = express.Router();

router.get('/', protectRoute, getQuote);
router.post('/addQuote', protectRoute, addQuotes);

export default router;