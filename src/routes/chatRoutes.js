const express = require('express');

const {
  getChats,
  getMessages,
  sendMessage,
  markMessagesAsRead,
  deleteMessage,
} = require('../controllers/chatController');

const {
  protect,
} = require('../middleware/auth');

const router = express.Router();

// =========================
// GET USER CHATS
// =========================
router.get(
  '/',
  protect,
  getChats
);

// =========================
// GET CHAT MESSAGES
// =========================
router.get(
  '/:chatId/messages',
  protect,
  getMessages
);

// =========================
// SEND MESSAGE
// =========================
router.post(
  '/send',
  protect,
  sendMessage
);

// =========================
// MARK AS READ
// =========================
router.put(
  '/:chatId/read',
  protect,
  markMessagesAsRead
);

// =========================
// DELETE MESSAGE
// =========================
router.delete(
  '/message/:messageId',
  protect,
  deleteMessage
);

module.exports = router;