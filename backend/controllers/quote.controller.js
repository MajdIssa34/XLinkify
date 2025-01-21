import Quote from '../models/quote.model.js';

export const getQuote = async (req, res) => {
    try {
        // Fetch a random quote using MongoDB's $sample aggregation
        const quotes = await Quote.aggregate([{ $sample: { size: 1 } }]);

        // Check if a quote was retrieved
        if (quotes.length === 0) {
            return res.status(404).json({ error: "No quotes available." });
        }

        // Return a correctly formatted response
        return res.status(200).json({
            quote: quotes[0].text,
            author: quotes[0].author,
        });
    } catch (error) {
        console.error("Error fetching quote:", error.message);
        return res.status(500).json({ error: "Internal server error." });
    }
};



export const addQuotes = async (req, res) => {
    const { text, author } = req.body; // Extract text and author from the request body

    if (!text || !author) {
        return res.status(400).json({ error: "Both 'text' and 'author' fields are required" });
    }

    try {
        const newQuote = new Quote({ text, author });
        await newQuote.save();

        res.status(201).json({
            message: "Quote added successfully",
            data: newQuote,
        });
    } catch (error) {
        console.error("Error in addQuote controller:", error.message);
        res.status(500).json({ error: "Internal server error" });
    }
};
