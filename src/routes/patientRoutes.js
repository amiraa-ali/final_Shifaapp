const express = require('express');
const { body } = require('express-validator');
const {
  getPatientProfile,
  updatePatientProfile,
  getMedicalConditions,
  uploadPatientImage,
  getPatientById,
} = require('../controllers/patientController');
const { protect, authorize } = require('../middleware/auth');
const validate = require('../middleware/validate');
const upload = require('../config/multer');

const router = express.Router();

/**
 * @swagger
 * tags:
 *   name: Patients
 *   description: Patient management endpoints
 */

/**
 * @swagger
 * /api/patients/profile:
 *   get:
 *     summary: Get patient profile
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Patient profile data
 *       404:
 *         description: Patient not found
 */
router.get('/profile', protect, authorize('patient'), getPatientProfile);

/**
 * @swagger
 * /api/patients/profile:
 *   put:
 *     summary: Update patient personal info (NOT medical conditions)
 *     tags: [Patients]
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
 *               phone:
 *                 type: string
 *               location:
 *                 type: string
 *               dateOfBirth:
 *                 type: string
 *                 format: date
 *               bloodType:
 *                 type: string
 *               allergies:
 *                 type: array
 *                 items:
 *                   type: string
 *     responses:
 *       200:
 *         description: Profile updated
 */
router.put(
  '/profile',
  protect,
  authorize('patient'),
  [
    body('name').optional().trim().isLength({ min: 2 }).withMessage('Name must be at least 2 characters'),
    body('phone').optional().trim(),
    body('dateOfBirth').optional().isISO8601().withMessage('Invalid date format'),
    body('bloodType')
      .optional()
      .isIn(['A+', 'A-', 'B+', 'B-', 'AB+', 'AB-', 'O+', 'O-', ''])
      .withMessage('Invalid blood type'),
  ],
  validate,
  updatePatientProfile
);

/**
 * @swagger
 * /api/patients/medical-conditions:
 *   get:
 *     summary: Get patient medical conditions (read-only)
 *     tags: [Patients]
 *     security:
 *       - bearerAuth: []
 *     responses:
 *       200:
 *         description: Medical conditions data
 */
router.get('/medical-conditions', protect, authorize('patient'), getMedicalConditions);

/**
 * @swagger
 * /api/patients/upload-image:
 *   post:
 *     summary: Upload patient profile image
 *     tags: [Patients]
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
router.post('/upload-image', protect, authorize('patient'), upload.single('image'), uploadPatientImage);

/**
 * @swagger
 * /api/patients/{id}:
 *   get:
 *     summary: Get patient by ID (for doctors)
 *     tags: [Patients]
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
 *         description: Patient details
 *       404:
 *         description: Patient not found
 */
router.get('/:id', protect, authorize('doctor'), getPatientById);

module.exports = router;
