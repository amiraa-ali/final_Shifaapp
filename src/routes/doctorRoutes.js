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
  getDoctorProfile, // ✅ ضيفي دي
} = require('../controllers/doctorController');

const { protect, authorize } = require('../middleware/auth');

const validate = require('../middleware/validate');

const upload = require('../config/multer');

const router = express.Router();

/**
 * GET ALL DOCTORS
 */
router.get('/', getAllDoctors);

/**
 * GET DOCTOR PROFILE
 * ✅ لازم يكون قبل /:id
 */
router.get(
  '/profile',
  protect,
  authorize('doctor'),
  getDoctorProfile
);

/**
 * UPDATE DOCTOR PROFILE
 */
router.put(
  '/profile',
  protect,
  authorize('doctor'),
  [
    body('fees')
        .optional()
        .isNumeric()
        .withMessage('Fees must be a number'),

    body('name')
        .optional()
        .trim()
        .isLength({ min: 2 })
        .withMessage('Name must be at least 2 characters'),
  ],

  validate,

  updateDoctorProfile
);

/**
 * UPLOAD DOCTOR IMAGE
 */
router.post(
  '/upload-image',
  protect,
  authorize('doctor'),
  upload.single('image'),
  uploadDoctorImage
);

/**
 * COMPLETED APPOINTMENTS
 */
router.get(
  '/appointments/completed',
  protect,
  authorize('doctor'),
  getCompletedAppointments
);

/**
 * PATIENT STATS
 */
router.get(
  '/stats/patients',
  protect,
  authorize('doctor'),
  getTotalPatients
);

/**
 * UPDATE PATIENT MEDICAL CONDITIONS
 */
router.put(
  '/patients/:patientId/medical-conditions',
  protect,
  authorize('doctor'),
  updatePatientMedicalConditions
);

/**
 * GET DOCTOR BY ID
 * ✅ خليها آخر route
 */
router.get('/:id', getDoctorById);

module.exports = router;