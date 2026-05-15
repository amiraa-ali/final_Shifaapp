const Message = require('../models/Message');
const Appointment = require('../models/Appointment');

// ======================================================
// GET USER CHATS
// ======================================================
exports.getChats = async (
  req,
  res
) => {
  try {
    const userId = req.user.id;

    let appointments = [];

    // =========================
    // PATIENT
    // =========================
    if (
      req.user.role === 'patient'
    ) {
      appointments =
        await Appointment.find({
          patientId: userId,
        })
          .populate(
            'doctorId',
            'name specialization profileImage'
          )
          .sort({
            updatedAt: -1,
          });
    }

    // =========================
    // DOCTOR
    // =========================
    else {
      appointments =
        await Appointment.find({
          doctorId: userId,
        })
          .populate(
            'patientId',
            'name profileImage'
          )
          .sort({
            updatedAt: -1,
          });
    }

    const chats = await Promise.all(
      appointments.map(
        async (appointment) => {
          const lastMessage =
            await Message.findOne({
              chatId:
                appointment._id,
            }).sort({
              createdAt: -1,
            });

          let unreadCount = 0;

          unreadCount =
            await Message.countDocuments(
              {
                chatId:
                  appointment._id,

                receiverId:
                  userId,

                isRead: false,
              }
            );

          return {
            _id: appointment._id,

            status:
              appointment.status,

            updatedAt:
              appointment.updatedAt,

            lastMessage:
              lastMessage
                ?.message ??
              '',

            unreadCount,

            // =================
            // PATIENT VIEW
            // =================
            ...(req.user.role ===
            'patient'
              ? {
                  doctorId:
                    appointment
                      .doctorId
                      ?._id,

                  doctorName:
                    appointment
                      .doctorId
                      ?.name,

                  specialization:
                    appointment
                      .doctorId
                      ?.specialization,

                  doctorImage:
                    appointment
                      .doctorId
                      ?.profileImage,
                }

              // =================
              // DOCTOR VIEW
              // =================
              : {
                  patientId:
                    appointment
                      .patientId
                      ?._id,

                  patientName:
                    appointment
                      .patientId
                      ?.name,

                  patientImage:
                    appointment
                      .patientId
                      ?.profileImage,
                }),
          };
        }
      )
    );

    res.status(200).json({
      success: true,

      chats,
    });
  } catch (error) {
    res.status(500).json({
      success: false,

      message:
        'Failed to load chats',

      error: error.message,
    });
  }
};

// ======================================================
// GET MESSAGES
// ======================================================
exports.getMessages = async (
  req,
  res
) => {
  try {
    const { chatId } = req.params;

    const messages =
      await Message.find({
        chatId,

        deletedFor: {
          $ne: req.user.id,
        },
      }).sort({
        createdAt: 1,
      });

    res.status(200).json({
      success: true,

      messages,
    });
  } catch (error) {
    res.status(500).json({
      success: false,

      message:
        'Failed to load messages',

      error: error.message,
    });
  }
};

// ======================================================
// SEND MESSAGE
// ======================================================
exports.sendMessage = async (
  req,
  res
) => {
  try {
    const {
      chatId,
      receiverId,
      message,
    } = req.body;

    // =========================
    // VALIDATION
    // =========================
    if (
      !chatId ||
      !receiverId ||
      !message
    ) {
      return res
        .status(400)
        .json({
          success: false,

          message:
            'Missing required fields',
        });
    }

    // =========================
    // CHECK APPOINTMENT
    // =========================
    const appointment =
      await Appointment.findById(
        chatId
      );

    if (!appointment) {
      return res
        .status(404)
        .json({
          success: false,

          message:
            'Appointment not found',
        });
    }

    // =========================
    // CHECK ACCESS
    // =========================
    const isParticipant =
      appointment.patientId.toString() ===
        req.user.id ||
      appointment.doctorId.toString() ===
        req.user.id;

    if (!isParticipant) {
      return res
        .status(403)
        .json({
          success: false,

          message:
            'Access denied',
        });
    }

    // =========================
    // CREATE MESSAGE
    // =========================
    const newMessage =
      await Message.create({
        chatId,

        senderId: req.user.id,

        receiverId,

        senderRole:
          req.user.role,

        message,
      });

    // تحديث appointment
    appointment.updatedAt =
      new Date();

    await appointment.save();

    res.status(201).json(
      newMessage
    );
  } catch (error) {
    res.status(500).json({
      success: false,

      message:
        'Failed to send message',

      error: error.message,
    });
  }
};

// ======================================================
// MARK AS READ
// ======================================================
exports.markMessagesAsRead =
  async (req, res) => {
    try {
      const { chatId } =
        req.params;

      await Message.updateMany(
        {
          chatId,

          receiverId:
            req.user.id,

          isRead: false,
        },

        {
          isRead: true,
        }
      );

      res.status(200).json({
        success: true,

        message:
          'Messages marked as read',
      });
    } catch (error) {
      res.status(500).json({
        success: false,

        message:
          'Failed to update messages',

        error: error.message,
      });
    }
  };

// ======================================================
// DELETE MESSAGE
// ======================================================
exports.deleteMessage =
  async (req, res) => {
    try {
      const { messageId } =
        req.params;

      const message =
        await Message.findById(
          messageId
        );

      if (!message) {
        return res
          .status(404)
          .json({
            success: false,

            message:
              'Message not found',
          });
      }

      // فقط صاحب الرسالة
      if (
        message.senderId.toString() !==
        req.user.id
      ) {
        return res
          .status(403)
          .json({
            success: false,

            message:
              'Access denied',
          });
      }

      // Soft delete
      message.deletedFor.push(
        req.user.id
      );

      await message.save();

      res.status(200).json({
        success: true,

        message:
          'Message deleted',
      });
    } catch (error) {
      res.status(500).json({
        success: false,

        message:
          'Failed to delete message',

        error: error.message,
      });
    }
  };