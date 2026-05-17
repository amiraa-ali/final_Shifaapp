const User = require('../models/User');
const Doctor = require('../models/Doctor');
const Appointment = require('../models/Appointment');
const asyncHandler = require('../middleware/asyncHandler');

/**
 * @desc    Get all doctors with pagination and search
 * @route   GET /api/doctors
 * @access  Public
 */
const getAllDoctors = asyncHandler(async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const skip = (page - 1) * limit;
  const search = req.query.search || '';
  const specialization = req.query.specialization || '';

  // Build user filter for search
  const userFilter = { role: 'doctor', isActive: true };
  if (search) {
    userFilter.name = { $regex: search, $options: 'i' };
  }

  // Find matching users
  const matchingUsers = await User.find(userFilter).select('_id');
  const userIds = matchingUsers.map((u) => u._id);

  // Build doctor filter
  const doctorFilter = { userId: { $in: userIds } };
  if (specialization) {
    doctorFilter.specialization = { $regex: specialization, $options: 'i' };
  }

  const total = await Doctor.countDocuments(doctorFilter);
  const doctors = await Doctor.find(doctorFilter)
    .populate('userId', 'name email profileImage')
    .skip(skip)
    .limit(limit)
    .sort({ createdAt: -1 });

  res.status(200).json({
    success: true,
    data: {
      doctors,
      pagination: {
        total,
        page,
        limit,
        pages: Math.ceil(total / limit),
      },
    },
  });
});

/**
 * @desc    Get doctor by ID
 * @route   GET /api/doctors/:id
 * @access  Public
 */
const getDoctorById = asyncHandler(async (req, res) => {
  const doctor = await Doctor.findById(req.params.id).populate(
    'userId',
    'name email profileImage createdAt'
  );

  if (!doctor) {
    return res.status(404).json({ success: false, message: 'Doctor not found' });
  }

  res.status(200).json({ success: true, data: doctor });
});

/**
 * @desc    Update doctor profile
 * @route   PUT /api/doctors/profile
 * @access  Private (Doctor only)
 */
const updateDoctorProfile = asyncHandler(async (req, res) => {

  const {

    name,
    phone,
    specialization,
    fees,
    about,
    clinicLocation,
    university,
    certificate,
    imageUrl,
    availability,

  } = req.body;

  // =========================
  // UPDATE USER
  // =========================

  const userUpdates = {};

  if (name !== undefined)
    userUpdates.name = name;

  if (phone !== undefined)
    userUpdates.phone = phone;

  if (imageUrl !== undefined)
    userUpdates.profileImage = imageUrl;

  if (Object.keys(userUpdates).length > 0) {

    await User.findByIdAndUpdate(
      req.user.id,
      { $set: userUpdates },
      { new: true },
    );
  }

  // =========================
  // UPDATE DOCTOR
  // =========================

  const updateFields = {};

  if (specialization !== undefined)
    updateFields.specialization =
        specialization;

  if (fees !== undefined)
    updateFields.fees = fees;

  if (about !== undefined)
    updateFields.about = about;

  if (clinicLocation !== undefined)
    updateFields.clinicLocation =
        clinicLocation;

  if (university !== undefined)
    updateFields.university =
        university;

  if (certificate !== undefined)
    updateFields.certificate =
        certificate;

  if (availability !== undefined)
    updateFields.availability =
        availability;

  if (imageUrl !== undefined)
    updateFields.imageUrl =
        imageUrl;

  const doctor =
      await Doctor.findOneAndUpdate(

    { userId: req.user.id },

    { $set: updateFields },

    {
      new: true,
      runValidators: true,
    },

  ).populate(
    'userId',
    'name email profileImage',
  );

  if (!doctor) {

    return res.status(404).json({

      success: false,

      message:
          'Doctor profile not found',
    });
  }

  res.status(200).json({

    success: true,

    message:
        'Profile updated successfully',

    data: doctor,
  });
});

/**
 * @desc    Upload doctor profile image
 * @route   POST /api/doctors/upload-image
 * @access  Private (Doctor only)
 */
const uploadDoctorImage = asyncHandler(async (req, res) => {
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
 * @desc    Get doctor's completed appointments
 * @route   GET /api/doctors/appointments/completed
 * @access  Private (Doctor only)
 */
const getCompletedAppointments = asyncHandler(async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const skip = (page - 1) * limit;

  const total = await Appointment.countDocuments({
    doctorId: req.user.id,
    status: 'completed',
  });

  const appointments = await Appointment.find({
    doctorId: req.user.id,
    status: 'completed',
  })
    .populate('patientId', 'name email profileImage')
    .skip(skip)
    .limit(limit)
    .sort({ appointmentDate: -1 });

  res.status(200).json({
    success: true,
    data: {
      appointments,
      pagination: { total, page, limit, pages: Math.ceil(total / limit) },
    },
  });
});

/**
 * @desc    Get total unique patients for a doctor
 * @route   GET /api/doctors/stats/patients
 * @access  Private (Doctor only)
 */
const getTotalPatients = asyncHandler(async (req, res) => {
  const uniquePatients = await Appointment.distinct('patientId', {
    doctorId: req.user.id,
  });

  const completedCount = await Appointment.countDocuments({
    doctorId: req.user.id,
    status: 'completed',
  });

  const pendingCount = await Appointment.countDocuments({
    doctorId: req.user.id,
    status: { $in: ['pending', 'confirmed'] },
  });

  res.status(200).json({
    success: true,
    data: {
      totalPatients: uniquePatients.length,
      completedAppointments: completedCount,
      pendingAppointments: pendingCount,
    },
  });
});

/**
 * @desc    Update patient medical conditions (Doctor only)
 * @route   PUT /api/doctors/patients/:patientId/medical-conditions
 * @access  Private (Doctor only)
 */
const updatePatientMedicalConditions = asyncHandler(async (req, res) => {
  const { medicalConditions } = req.body;
  const { patientId } = req.params;

  const Patient = require('../models/Patient');
  const patient = await Patient.findOneAndUpdate(
    { userId: patientId },
    { $set: { medicalConditions } },
    { new: true, runValidators: true }
  );

  if (!patient) {
    return res.status(404).json({ success: false, message: 'Patient not found' });
  }

  res.status(200).json({
    success: true,
    message: 'Medical conditions updated successfully',
    data: patient,
  });
});
const getDoctorProfile = async (req, res) => {
  try {

    const doctor = await Doctor.findOne({
      userId: req.user._id,
    }).populate('userId');

    if (!doctor) {
      return res.status(404).json({
        success: false,
        message: 'Doctor not found',
      });
    }

    res.status(200).json({
      success: true,
      data: doctor,
    });

  } catch (error) {

    res.status(500).json({
      success: false,
      message: error.message,
    });

  }
};

module.exports = {
  getAllDoctors,
  getDoctorById,
  updateDoctorProfile,
  uploadDoctorImage,
  getCompletedAppointments,
  getTotalPatients,
  updatePatientMedicalConditions,
  getDoctorProfile, // ✅ ضيفي دي
};