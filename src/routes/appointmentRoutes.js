const express = require('express');
const { body } = require('express-validator');
const {
  createAppointment,
  cancelAppointment,
  completeAppointment,
  confirmAppointment,
  getDoctorAppointments,
  getPatientAppointments,
  getAppointmentById,
} = require('../controllers/appointmentController');
const { protect, authorize } = require('../middleware/auth');
const validate = require('../middleware/validate');

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Appointments
 *   description: Appointment management endpoints
 */

/**
 * @swagger
 * /api/appointments:
 *   post:
 *     summary: Create a new appointment
 *     tags: [Appointments]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       required: true
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             required: [doctorId, appointmentDate]
 *             properties:
 *               doctorId:
 *                 type: string
 *               appointmentDate:
 *                 type: string
 *                 format: date-time
 *               notes:
 *                 type: string
 *     responses:
 *       201:
 *         description: Appointment created
 *       409:
 *         description: Time slot already booked
 */
router.post(
  '/',
  protect,
  authorize('patient'),
  [
    body('doctorId').notEmpty().withMessage('Doctor ID is required').isMongoId().withMessage('Invalid Doctor ID'),
    body('appointmentDate').notEmpty().withMessage('Appointment date is required').isISO8601().withMessage('Invalid date format'),
    body('notes').optional().isLength({ max: 500 }).withMessage('Notes cannot exceed 500 characters'),
  ],
  validate,
  createAppointment
);

/**
 * @swagger
 * /api/appointments/doctor:
 *   get:
 *     summary: Get doctor's appointments
 *     tags: [Appointments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: filter
 *         schema:
 *           type: string
 *           enum: [all, upcoming, past]
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Doctor appointments list
 */
router.get('/doctor', protect, authorize('doctor'), getDoctorAppointments);

/**
 * @swagger
 * /api/appointments/patient:
 *   get:
 *     summary: Get patient's appointments
 *     tags: [Appointments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: query
 *         name: filter
 *         schema:
 *           type: string
 *           enum: [all, upcoming, past]
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *     responses:
 *       200:
 *         description: Patient appointments list
 */
router.get('/patient', protect, authorize('patient'), getPatientAppointments);

/**
 * @swagger
 * /api/appointments/{id}:
 *   get:
 *     summary: Get appointment by ID
 *     tags: [Appointments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Appointment details
 *       403:
 *         description: Not authorized
 *       404:
 *         description: Not found
 */
router.get('/:id', protect, getAppointmentById);

/**
 * @swagger
 * /api/appointments/{id}/cancel:
 *   put:
 *     summary: Cancel an appointment
 *     tags: [Appointments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               cancelReason:
 *                 type: string
 *     responses:
 *       200:
 *         description: Appointment cancelled
 */
router.put('/:id/cancel', protect, cancelAppointment);

/**
 * @swagger
 * /api/appointments/{id}/confirm:
 *   put:
 *     summary: Confirm an appointment (Doctor only)
 *     tags: [Appointments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Appointment confirmed
 */
router.put('/:id/confirm', protect, authorize('doctor'), confirmAppointment);

/**
 * @swagger
 * /api/appointments/{id}/complete:
 *   put:
 *     summary: Complete an appointment (Doctor only)
 *     tags: [Appointments]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               doctorNotes:
 *                 type: string
 *     responses:
 *       200:
 *         description: Appointment completed
 */
router.put('/:id/complete', protect, authorize('doctor'), completeAppointment);

module.exports = router;
