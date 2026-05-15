const mongoose = require('mongoose');

const messageSchema = new mongoose.Schema(
  {
    chatId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'Appointment',

      required: true,
    },

    senderId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',

      required: true,
    },

    receiverId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',

      required: true,
    },

    senderRole: {
      type: String,

      enum: ['patient', 'doctor'],

      required: true,
    },

    message: {
      type: String,

      required: true,

      trim: true,

      maxlength: 2000,
    },

    isRead: {
      type: Boolean,

      default: false,
    },

    deletedFor: [
      {
        type: mongoose.Schema.Types.ObjectId,
        ref: 'User',
      },
    ],
  },

  {
    timestamps: true,
  }
);

// =========================
// INDEXES
// =========================

messageSchema.index({
  chatId: 1,
  createdAt: 1,
});

messageSchema.index({
  senderId: 1,
});

messageSchema.index({
  receiverId: 1,
});

module.exports = mongoose.model(
  'Message',
  messageSchema
);