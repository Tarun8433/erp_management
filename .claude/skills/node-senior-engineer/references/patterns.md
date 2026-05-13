# Node.js Patterns Reference

## Mongoose Schema Pattern
```js
import mongoose from 'mongoose';

const Schema = new mongoose.Schema(
  {
    name:     { type: String, required: true, trim: true },
    status:   { type: String, enum: ['active', 'inactive'], default: 'active' },
    amount:   { type: Number, required: true, min: 0 },
    user:     { type: mongoose.Schema.Types.ObjectId, ref: 'User', required: true },
    tags:     [{ type: String, trim: true }],
  },
  { timestamps: true }
);

// Index fields used in queries
Schema.index({ user: 1, createdAt: -1 });
Schema.index({ status: 1 });

export default mongoose.model('ModelName', Schema);
```

## Zod Validation Schema
```js
import { z } from 'zod';

export const createSchema = z.object({
  body: z.object({
    name:     z.string().min(1).max(200).trim(),
    amount:   z.number().positive(),
    userId:   z.string().length(24),            // MongoDB ObjectId
    status:   z.enum(['active', 'inactive']).optional(),
  }),
});

export const updateSchema = z.object({
  params: z.object({ id: z.string().length(24) }),
  body:   z.object({
    name:   z.string().min(1).max(200).trim().optional(),
    status: z.enum(['active', 'inactive']).optional(),
  }),
});
```

## Route File Pattern
```js
import express from 'express';
import { getAll, getOne, create, update, remove } from '../controllers/resourceController.js';
import { protect } from '../middleware/auth.js';
import { admin } from '../middleware/admin.js';
import validate from '../middleware/validate.js';
import { createSchema, updateSchema } from '../schemas/resource.js';

const router = express.Router();

router.get('/',       protect, getAll);
router.get('/:id',    protect, getOne);
router.post('/',      protect, validate(createSchema), create);
router.put('/:id',    protect, validate(updateSchema), update);
router.delete('/:id', protect, admin, remove);

export default router;
```

## Socket.io Emit from Controller
```js
import { getIO } from '../utils/socket.js';

// Inside a controller function, after a DB write:
const io = getIO();
io.to(`user_${recipientId}`).emit('notification', { message: 'You have a new order' });
```

## Firebase Push Notification
```js
import admin from 'firebase-admin';

export const sendPushNotification = async (fcmToken, title, body, data = {}) => {
  if (!fcmToken) return;
  try {
    await admin.messaging().send({
      token: fcmToken,
      notification: { title, body },
      data,
    });
  } catch (error) {
    console.error('Push notification failed:', error);
    // Don't throw — notification failure should not break the main flow
  }
};
```

## Aggregation Pipeline Pattern
```js
// Always $match first to use indexes
const results = await Order.aggregate([
  { $match: { user: new mongoose.Types.ObjectId(userId), status: 'delivered' } },
  { $lookup: { from: 'products', localField: 'items.product', foreignField: '_id', as: 'productDetails' } },
  { $project: { _id: 1, total: 1, createdAt: 1 } },  // project early to reduce data
  { $sort: { createdAt: -1 } },
  { $skip: skip },
  { $limit: limit },
]);
```

## JWT Token Generation
```js
// utils/generateToken.js
import jwt from 'jsonwebtoken';

const generateToken = (id) => {
  return jwt.sign({ id }, process.env.JWT_SECRET, {
    expiresIn: process.env.JWT_EXPIRES_IN || '30d',
  });
};

export default generateToken;
```

## Ownership Check Pattern
```js
const resource = await Model.findById(req.params.id).lean();
if (!resource) return res.status(404).json({ message: 'Not found' });

// Check ownership — admin can bypass
if (resource.user.toString() !== req.user._id.toString() && !req.user.isAdmin) {
  return res.status(403).json({ message: 'Not authorized' });
}
```
