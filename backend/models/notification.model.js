import mongoose from 'mongoose';

const notificationSchema = new mongoose.Schema(
  {
    from: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    to: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
    },
    type: {
      type: String,
      required: true,
      enum: ['like', 'watchlist'],
    },
    description: {
      type: String,
      required: true, // Description is now mandatory
    },
    read: {
      type: Boolean,
      default: false,
    },
  },
  { timestamps: true }
);

// Add pre-save middleware to dynamically set the description
notificationSchema.pre('save', async function (next) {
  if (this.isNew || this.isModified('type')) {
    const userFrom = await mongoose.model('User').findById(this.from).select('username');
    if (!userFrom) {
      throw new Error('User not found for the "from" field');
    }

    if (this.type === 'like') {
      this.description = `${userFrom.username} liked your post.`;
    } else if (this.type === 'watchlist') {
      this.description = `${userFrom.username} added you to their watchlist.`;
    }
  }
  next();
});

const Notification = mongoose.model('Notification', notificationSchema);

export default Notification;
