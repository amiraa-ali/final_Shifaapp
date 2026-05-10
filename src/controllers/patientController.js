const User = require('../models/User');
const Patient = require('../models/Patient');
const asyncHandler = require('../middleware/asyncHandler');

/**
 * @desc    Get patient profile
 * @route   GET /api/patients/profile
 * @access  Private (Patient only)
 */
const getPatientProfile = asyncHandler(async (req, res) => {
  const user = await User.findById(req.user.id);
  const patient = await Patient.findOne({ userId: req.user.id });

  if (!patient) {
    return res.status(404).json({ success: false, message: 'Patient profile not found' });
  }

  res.status(200).json({
    success: true,
    data: {
      user,
      patient,
    },
  });
});

/**
 * @desc    Update patient profile (personal info only - NOT medical conditions)
 * @route   PUT /api/patients/profile
 * @access  Private (Patient only)
 */
const updatePatientProfile = asyncHandler(async (req, res) => {
  const { name, phone, location, dateOfBirth, bloodType, allergies, emergencyContact } = req.body;

  // Update user name if provided
  if (name) {
    await User.findByIdAndUpdate(req.user.id, { name }, { runValidators: true });
  }

  const updateFields = {};
  if (phone !== undefined) updateFields.phone = phone;
  if (location !== undefined) updateFields.location = location;
  if (dateOfBirth !== undefined) updateFields.dateOfBirth = dateOfBirth;
  if (bloodType !== undefined) updateFields.bloodType = bloodType;
  if (allergies !== undefined) updateFields.allergies = allergies;
  if (emergencyContact !== undefined) updateFields.emergencyContact = emergencyContact;

  const patient = await Patient.findOneAndUpdate(
    { userId: req.user.id },
    { $set: updateFields },
    { new: true, runValidators: true }
  );

  if (!patient) {
    return res.status(404).json({ success: false, message: 'Patient profile not found' });
  }

  const user = await User.findById(req.user.id);

  res.status(200).json({
    success: true,
    message: 'Profile updated successfully',
    data: { user, patient },
  });
});

/**
 * @desc    Get patient medical conditions (read-only for patient)
 * @route   GET /api/patients/medical-conditions
 * @access  Private (Patient only)
 */
const getMedicalConditions = asyncHandler(async (req, res) => {
  const patient = await Patient.findOne({ userId: req.user.id }).select(
    'medicalConditions bloodType allergies'
  );

  if (!patient) {
    return res.status(404).json({ success: false, message: 'Patient profile not found' });
  }

  res.status(200).json({
    success: true,
    data: {
      medicalConditions: patient.medicalConditions,
      bloodType: patient.bloodType,
      allergies: patient.allergies,
    },
  });
});

/**
 * @desc    Upload patient profile image
 * @route   POST /api/patients/upload-image
 * @access  Private (Patient only)
 */
const uploadPatientImage = asyncHandler(async (req, res) => {
  if (!req.file) {
    return res.status(400).json({ success: false, message: 'No image file provided' });
  }

  const imageUrl = `${req.protocol}://${req.get('host')}/uploads/profiles/${req.file.filename}`;

  await User.findByIdAndUpdate(req.user.id, { profileImage: imageUrl });

  res.status(200).json({
    success: true,
    message: 'Image uploaded successfully',
    data: { imageUrl },
  });
});

/**
 * @desc    Get patient by ID (for doctors to view)
 * @route   GET /api/patients/:id
 * @access  Private (Doctor only)
 */
const getPatientById = asyncHandler(async (req, res) => {
  const user = await User.findById(req.params.id);
  if (!user || user.role !== 'patient') {
    return res.status(404).json({ success: false, message: 'Patient not found' });
  }

  const patient = await Patient.findOne({ userId: req.params.id });

  res.status(200).json({
    success: true,
    data: { user, patient },
  });
});

module.exports = {
  getPatientProfile,
  updatePatientProfile,
  getMedicalConditions,
  uploadPatientImage,
  getPatientById,
};
