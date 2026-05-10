const Appointment = require('../models/Appointment');

/**
 * Check if a time slot is available for a doctor
 * @param {string} doctorId - Doctor user ID
 * @param {Date} appointmentDate - Requested appointment date
 * @param {string} excludeId - Appointment ID to exclude (for rescheduling)
 * @returns {boolean} True if slot is available
 */
const isSlotAvailable = async (doctorId, appointmentDate, excludeId = null) => {
  const query = {
    doctorId,
    appointmentDate: new Date(appointmentDate),
    status: { $in: ['pending', 'confirmed'] },
  };

  if (excludeId) {
    query._id = { $ne: excludeId };
  }

  const existing = await Appointment.findOne(query);
  return !existing;
};

/**
 * Get appointment statistics for a doctor
 * @param {string} doctorId - Doctor user ID
 * @returns {object} Stats object
 */
const getDoctorStats = async (doctorId) => {
  const [total, completed, pending, confirmed, cancelled, uniquePatients] = await Promise.all([
    Appointment.countDocuments({ doctorId }),
    Appointment.countDocuments({ doctorId, status: 'completed' }),
    Appointment.countDocuments({ doctorId, status: 'pending' }),
    Appointment.countDocuments({ doctorId, status: 'confirmed' }),
    Appointment.countDocuments({ doctorId, status: 'cancelled' }),
    Appointment.distinct('patientId', { doctorId }),
  ]);

  return {
    total,
    completed,
    pending,
    confirmed,
    cancelled,
    totalPatients: uniquePatients.length,
  };
};

/**
 * Get appointment statistics for a patient
 * @param {string} patientId - Patient user ID
 * @returns {object} Stats object
 */
const getPatientStats = async (patientId) => {
  const [total, completed, pending, confirmed, cancelled] = await Promise.all([
    Appointment.countDocuments({ patientId }),
    Appointment.countDocuments({ patientId, status: 'completed' }),
    Appointment.countDocuments({ patientId, status: 'pending' }),
    Appointment.countDocuments({ patientId, status: 'confirmed' }),
    Appointment.countDocuments({ patientId, status: 'cancelled' }),
  ]);

  return { total, completed, pending, confirmed, cancelled };
};

module.exports = { isSlotAvailable, getDoctorStats, getPatientStats };
