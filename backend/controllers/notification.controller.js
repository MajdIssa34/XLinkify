import Notification from "../models/notification.model.js";

export const getNotifications = async (req, res) => {
    try {
        const userId = req.user._id;

        const notifications = await Notification.find({ to: userId })
            .sort({ createdAt: -1 })
            .populate({ path: 'from', select: 'username profileImg' });

        // Add description for each notification
        const notificationsWithDescription = notifications.map((notification) => {
            let description = "";

            if (notification.type === "like") {
                description = `${notification.from.username} liked your post.`;
            } else if (notification.type === "watchlist") {
                description = `${notification.from.username} added you to their watchlist.`;
            }

            return {
                ...notification.toObject(), // Convert Mongoose document to plain object
                description, // Add the description
            };
        });

        // Mark all notifications as read
        await Notification.updateMany({ to: userId }, { read: true });

        res.status(200).json({ notifications: notificationsWithDescription });
    } catch (error) {
        console.log("Error in getNotifications", error);
        res.status(500).json({ error: "internal server error" });
    }
};


export const deleteNotifications = async (req, res) => {
    try {
        const userId  = req.user._id;

        await Notification.deleteMany({to: userId});

        res.status(200).json({message: "Deleted notification"});
    } catch (error) {
        res.status(500).json({error: "internal server error"});
        console.log("Error in deleteNotifications", error);
    }
}