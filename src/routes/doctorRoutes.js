const express = require('express');
const { body } = require('express-validator');
const {
  getAllDoctors,
  getDoctorById,
  updateDoctorProfile,
  uploadDoctorImage,
  getCompletedAppointments,
  getTotalPatients,
  updatePatientMedicalConditions,
} = require('../controllers/doctorController');
const { protect, authorize } = require('../middleware/auth');
const validate = require('../middleware/validate');
const upload = require('../config/multer');

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Doctors
 *   description: Doctor management endpoints
 */

/**
 * @swagger
 * /api/doctors:
 *   get:
 *     summary: Get all doctors with pagination and search
 *     tags: [Doctors]
 *     security: []
 *     parameters:
 *       - in: query
 *         name: page
 *         schema:
 *           type: integer
 *         description: Page number
 *       - in: query
 *         name: limit
 *         schema:
 *           type: integer
 *         description: Results per page
 *       - in: query
 *         name: search
 *         schema:
 *           type: string
 *         description: Search by doctor name
 *       - in: query
 *         name: specialization
 *         schema:
 *           type: string
 *         description: Filter by specialization
 *     responses:
 *       200:
 *         description: List of doctors
 */
router.get('/', getAllDoctors);

/**
 * @swagger
 * /api/doctors/profile:
 *   put:
 *     summary: Update doctor profile
 *     tags: [Doctors]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               name:
 *                 type: string
 *               specialization:
 *                 type: string
 *               fees:
 *                 type: number
 *               about:
 *                 type: string
 *               clinicLocation:
 *                 type: string
 *               university:
 *                 type: string
 *     responses:
 *       200:
 *         description: Profile updated
 */
router.put(
  '/profile',
  protect,
  authorize('doctor'),
  [
    body('fees').optional().isNumeric().withMessage('Fees must be a number'),
    body('name').optional().trim().isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
  ],
  validate,
  updateDoctorProfile
);

/**
 * @swagger
 * /api/doctors/upload-image:
 *   post:
 *     summary: Upload doctor profile image
 *     tags: [Doctors]
 *     security:
 *       - bearerAuth: []
 *     requestBody:
 *       content:
 *         multipart/form-data:
 *           schema:
 *             type: object
 *             properties:
 *               image:
 *                 type: string
 *                 format: binary
 *     responses:
 *       200:
 *         description: Image uploaded
 */
router.post('/upload-image', protect, authorize('doctor'), upload.single('image'), uploadDoctorImage);

/**
 * @swagger
 * /api/doctors/appointments/completed:
 *   get:
 *     summary: Get doctor's completed appointments
 *     tags: [Doctors]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Completed appointments list
 */
router.get('/appointments/completed', protect, authorize('doctor'), getCompletedAppointments);

/**
 * @swagger
 * /api/doctors/stats/patients:
 *   get:
 *     summary: Get total patients and appointment stats
 *     tags: [Doctors]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Patient statistics
 */
router.get('/stats/patients', protect, authorize('doctor'), getTotalPatients);

/**
 * @swagger
 * /api/doctors/patients/{patientId}/medical-conditions:
 *   put:
 *     summary: Update patient medical conditions (Doctor only)
 *     tags: [Doctors]
 *     security:
 *       - bearerAuth: []
 *     parameters:
 *       - in: path
 *         name: patientId
 *         required: true
 *         schema:
 *           type: string
 *     requestBody:
 *       content:
 *         application/json:
 *           schema:
 *             type: object
 *             properties:
 *               medicalConditions:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       200:
 *         description: Medical conditions updated
 */
router.put(
  '/patients/:patientId/medical-conditions',
  protect,
  authorize('doctor'),
  updatePatientMedicalConditions
);

/**
 * @swagger
 * /api/doctors/{id}:
 *   get:
 *     summary: Get doctor by ID
 *     tags: [Doctors]
 *     security: []
 *     parameters:
 *       - in: path
 *         name: id
 *         required: true
 *         schema:
 *           type: string
 *     responses:
 *       200:
 *         description: Doctor details
 *       404:
 *         description: Doctor not found
 */
router.get('/:id', getDoctorById);

module.exports = router;
