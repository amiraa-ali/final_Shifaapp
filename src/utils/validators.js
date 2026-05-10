const { body, param } = require('express-validator');

// Common validation rules
const mongoIdParam = (paramName = 'id') =>
  param(paramName).isMongoId().withMessage(`Invalid ${paramName} format`);

const emailValidation = body('email')
  .isEmail()
  .withMessage('Valid email is required')
  .normalizeEmail();

const passwordValidation = body('password')
  .isLength({ min: 6 })
  .withMessage('Password must be at least 6 characters');

const nameValidation = body('name')
  .optional()
  .trim()
  .isLength({ min: 2, max: 100 })
  .withMessage('Name must be 2-100 characters');

const paginationValidation = [
  body('page').optional().isInt({ min: 1 }).withMessage('Page must be a positive integer'),
  body('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Limit must be between 1 and 100'),
];

module.exports = {
  mongoIdParam,
  emailValidation,
  passwordValidation,
  nameValidation,
  paginationValidation,
};
