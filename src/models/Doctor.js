const mongoose = require('mongoose');

/**
 * @swagger
 * components:
 *   schemas:
 *     Doctor:
 *       type: object
 *       properties:
 *         _id:
 *           type: string
 *         userId:
 *           type: string
 *         specialization:
 *           type: string
 *         fees:
 *           type: number
 *         about:
 *           type: string
 *         clinicLocation:
 *           type: string
 *         university:
 *           type: string
 *         certificate:
 *           type: string
 *         availability:
 *           type: array
 *           items:
 *             type: object
 */
const availabilitySchema = new mongoose.Schema(
  {
    day: {
      type: String,
      enum: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
      required: true,
    },
    startTime: { type: String, required: true },
    endTime: { type: String, required: true },
    isAvailable: { type: Boolean, default: true },
  },
  { _id: false }
);

const doctorSchema = new mongoose.Schema(
  {
    userId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true,
      unique: true,
    },
    specialization: {
      type: String,
      trim: true,
      default: '',
    },
    fees: {
      type: Number,
      min: [0, 'Fees cannot be negative'],
      default: 0,
    },
    about: {
      type: String,
      maxlength: [1000, 'About cannot exceed 1000 characters'],
      default: '',
    },
    clinicLocation: {
      type: String,
      trim: true,
      default: '',
    },
    university: {
      type: String,
      trim: true,
      default: '',
    },
    certificate: {
      type: String,
      default: null,
    },
    availability: {
      type: [availabilitySchema],
      default: [],
    },
    rating: {
      type: Number,
      min: 0,
      max: 5,
      default: 0,
    },
    totalReviews: {
      type: Number,
      default: 0,
    },
  },
  { timestamps: true }
);

// Virtual for full doctor info with user data
doctorSchema.virtual('user', {
  ref: 'User',
  localField: 'userId',
  foreignField: '_id',
  justOne: true,
});

module.exports = mongoose.model('Doctor', doctorSchema);
