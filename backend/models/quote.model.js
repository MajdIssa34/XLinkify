import mongoose from 'mongoose';

const quoteSchema = new mongoose.Schema(
  {
    quote: {
      type: String,
      required: true, // The quote text is mandatory
      trim: true,     // Remove leading/trailing whitespace
    },
    author: {
      type: String,
      default: 'Unknown', // Set a default if the author is not provided
      trim: true,
    },
    createdAt: {
      type: Date,
      default: Date.now, // Automatically set the timestamp when the quote is added
    },
  },
  { timestamps: true } // Automatically manage createdAt and updatedAt fields
);

const Quote = mongoose.model('Quote', quoteSchema);

export default Quote;
