const Appointment = require('../models/Appointment');
const Doctor = require('../models/Doctor');
const asyncHandler = require('../middleware/asyncHandler');

/**
 * @desc    Create a new appointment
 * @route   POST /api/appointments
 * @access  Private (Patient only)
 */
const createAppointment = asyncHandler(async (req, res) => {
  const { doctorId, appointmentDate, notes } = req.body;

  // Verify doctor exists
  const doctor = await Doctor.findOne({ userId: doctorId });
  if (!doctor) {
    return res.status(404).json({ success: false, message: 'Doctor not found' });
  }

  // Check for conflicting appointment (same doctor, same date, not cancelled)
  const conflict = await Appointment.findOne({
    doctorId,
    appointmentDate: new Date(appointmentDate),
    status: { $in: ['pending', 'confirmed'] },
  });

  if (conflict) {
    return res.status(409).json({
      success: false,
      message: 'This time slot is already booked. Please choose another time.',
    });
  }

  const appointment = await Appointment.create({
    patientId: req.user.id,
    doctorId,
    appointmentDate,
    notes,
    fee: doctor.fees,
  });

  const populated = await Appointment.findById(appointment._id)
    .populate('patientId', 'name email profileImage')
    .populate('doctorId', 'name email profileImage');

  res.status(201).json({
    success: true,
    message: 'Appointment created successfully',
    data: populated,
  });
});

/**
 * @desc    Cancel an appointment
 * @route   PUT /api/appointments/:id/cancel
 * @access  Private (Patient or Doctor)
 */
const cancelAppointment = asyncHandler(async (req, res) => {
  const appointment = await Appointment.findById(req.params.id);

  if (!appointment) {
    return res.status(404).json({ success: false, message: 'Appointment not found' });
  }

  // Only the patient or doctor involved can cancel
  const isPatient = appointment.patientId.toString() === req.user.id.toString();
  const isDoctor = appointment.doctorId.toString() === req.user.id.toString();

  if (!isPatient && !isDoctor) {
    return res.status(403).json({ success: false, message: 'Not authorized to cancel this appointment' });
  }

  if (appointment.status === 'completed') {
    return res.status(400).json({ success: false, message: 'Cannot cancel a completed appointment' });
  }

  if (appointment.status === 'cancelled') {
    return res.status(400).json({ success: false, message: 'Appointment is already cancelled' });
  }

  appointment.status = 'cancelled';
  appointment.cancelReason = req.body.cancelReason || '';
  await appointment.save();

  res.status(200).json({
    success: true,
    message: 'Appointment cancelled successfully',
    data: appointment,
  });
});

/**
 * @desc    Complete an appointment
 * @route   PUT /api/appointments/:id/complete
 * @access  Private (Doctor only)
 */
const completeAppointment = asyncHandler(async (req, res) => {
  const appointment = await Appointment.findById(req.params.id);

  if (!appointment) {
    return res.status(404).json({ success: false, message: 'Appointment not found' });
  }

  if (appointment.doctorId.toString() !== req.user.id.toString()) {
    return res.status(403).json({ success: false, message: 'Not authorized to complete this appointment' });
  }

  if (appointment.status === 'cancelled') {
    return res.status(400).json({ success: false, message: 'Cannot complete a cancelled appointment' });
  }

  if (appointment.status === 'completed') {
    return res.status(400).json({ success: false, message: 'Appointment is already completed' });
  }

  appointment.status = 'completed';
  if (req.body.doctorNotes) appointment.doctorNotes = req.body.doctorNotes;
  await appointment.save();

  res.status(200).json({
    success: true,
    message: 'Appointment marked as completed',
    data: appointment,
  });
});

/**
 * @desc    Confirm an appointment
 * @route   PUT /api/appointments/:id/confirm
 * @access  Private (Doctor only)
 */
const confirmAppointment = asyncHandler(async (req, res) => {
  const appointment = await Appointment.findById(req.params.id);

  if (!appointment) {
    return res.status(404).json({ success: false, message: 'Appointment not found' });
  }

  if (appointment.doctorId.toString() !== req.user.id.toString()) {
    return res.status(403).json({ success: false, message: 'Not authorized to confirm this appointment' });
  }

  if (appointment.status !== 'pending') {
    return res.status(400).json({ success: false, message: `Cannot confirm an appointment with status: ${appointment.status}` });
  }

  appointment.status = 'confirmed';
  await appointment.save();

  res.status(200).json({
    success: true,
    message: 'Appointment confirmed',
    data: appointment,
  });
});

/**
 * @desc    Get doctor's appointments (upcoming and past)
 * @route   GET /api/appointments/doctor
 * @access  Private (Doctor only)
 */
const getDoctorAppointments = asyncHandler(async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const skip = (page - 1) * limit;
  const filter = req.query.filter || 'all'; // all | upcoming | past

  const now = new Date();
  const query = { doctorId: req.user.id };

  if (filter === 'upcoming') {
    query.appointmentDate = { $gte: now };
    query.status = { $in: ['pending', 'confirmed'] };
  } else if (filter === 'past') {
    query.$or = [
      { appointmentDate: { $lt: now } },
      { status: { $in: ['completed', 'cancelled'] } },
    ];
  }

  const total = await Appointment.countDocuments(query);
  const appointments = await Appointment.find(query)
    .populate('patientId', 'name email profileImage')
    .skip(skip)
    .limit(limit)
    .sort({ appointmentDate: filter === 'upcoming' ? 1 : -1 });

  res.status(200).json({
    success: true,
    data: {
      appointments,
      pagination: { total, page, limit, pages: Math.ceil(total / limit) },
    },
  });
});

/**
 * @desc    Get patient's appointments (upcoming and past)
 * @route   GET /api/appointments/patient
 * @access  Private (Patient only)
 */
const getPatientAppointments = asyncHandler(async (req, res) => {
  const page = parseInt(req.query.page) || 1;
  const limit = parseInt(req.query.limit) || 10;
  const skip = (page - 1) * limit;
  const filter = req.query.filter || 'all'; // all | upcoming | past

  const now = new Date();
  const query = { patientId: req.user.id };

  if (filter === 'upcoming') {
    query.appointmentDate = { $gte: now };
    query.status = { $in: ['pending', 'confirmed'] };
  } else if (filter === 'past') {
    query.$or = [
      { appointmentDate: { $lt: now } },
      { status: { $in: ['completed', 'cancelled'] } },
    ];
  }

  const total = await Appointment.countDocuments(query);
  const appointments = await Appointment.find(query)
    .populate('doctorId', 'name email profileImage')
    .skip(skip)
    .limit(limit)
    .sort({ appointmentDate: filter === 'upcoming' ? 1 : -1 });

  res.status(200).json({
    success: true,
    data: {
      appointments,
      pagination: { total, page, limit, pages: Math.ceil(total / limit) },
    },
  });
});

/**
 * @desc    Get single appointment by ID
 * @route   GET /api/appointments/:id
 * @access  Private
 */
const getAppointmentById = asyncHandler(async (req, res) => {
  const appointment = await Appointment.findById(req.params.id)
    .populate('patientId', 'name email profileImage')
    .populate('doctorId', 'name email profileImage');

  if (!appointment) {
    return res.status(404).json({ success: false, message: 'Appointment not found' });
  }

  // Only the patient or doctor involved can view
  const isPatient = appointment.patientId._id.toString() === req.user.id.toString();
  const isDoctor = appointment.doctorId._id.toString() === req.user.id.toString();

  if (!isPatient && !isDoctor) {
    return res.status(403).json({ success: false, message: 'Not authorized to view this appointment' });
  }

  res.status(200).json({ success: true, data: appointment });
});

module.exports = {
  createAppointment,
  cancelAppointment,
  completeAppointment,
  confirmAppointment,
  getDoctorAppointments,
  getPatientAppointments,
  getAppointmentById,
};
