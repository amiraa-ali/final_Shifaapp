# 🏥 Healthcare App Backend API

A production-ready **Node.js + Express + MongoDB** REST API backend for a Healthcare Mobile App built with Flutter.

---

## 🚀 Tech Stack

| Technology | Purpose |
|---|---|
| Node.js | Runtime environment |
| Express.js | Web framework |
| MongoDB + Mongoose | Database & ODM |
| JWT | Authentication |
| bcryptjs | Password hashing |
| Multer | Image uploads |
| Swagger UI | API documentation |
| Helmet | Security headers |
| express-rate-limit | Rate limiting |
| compression | Response compression |

---

## 📁 Project Structure

```
src/
├── config/
│   ├── db.js              # MongoDB connection
│   ├── multer.js          # File upload config
│   └── swagger.js         # Swagger/OpenAPI config
├── controllers/
│   ├── authController.js
│   ├── doctorController.js
│   ├── patientController.js
│   └── appointmentController.js
├── middleware/
│   ├── asyncHandler.js    # Async error wrapper
│   ├── auth.js            # JWT protect + role authorize
│   ├── errorHandler.js    # Global error handler
│   ├── notFound.js        # 404 handler
│   └── validate.js        # express-validator checker
├── models/
│   ├── User.js
│   ├── Doctor.js
│   ├── Patient.js
│   └── Appointment.js
├── routes/
│   ├── authRoutes.js
│   ├── doctorRoutes.js
│   ├── patientRoutes.js
│   └── appointmentRoutes.js
├── services/
│   ├── authService.js
│   └── appointmentService.js
├── utils/
│   ├── constants.js
│   ├── response.js
│   └── validators.js
└── server.js              # Entry point
uploads/
└── profiles/              # Uploaded images
```

---

## ⚙️ Setup & Installation

### Prerequisites
- Node.js v18+
- MongoDB (local or Atlas)
- npm or yarn

### 1. Clone & Install

```bash
cd healthcare-backend
npm install
```

### 2. Environment Variables

```bash
cp .env.example .env
```

Edit `.env` with your values:

```env
NODE_ENV=development
PORT=5000
MONGO_URI=mongodb://localhost:27017/healthcare_db
JWT_SECRET=your_super_secret_key_min_32_chars
JWT_EXPIRE=30d
```

### 3. Run the Server

```bash
# Development (with auto-reload)
npm run dev

# Production
npm start
```

---

## 📚 API Documentation

Once the server is running, visit:

```
http://localhost:5000/api/docs
```

Swagger UI provides interactive documentation for all endpoints.

---

## 🔗 API Endpoints

### 🔐 Authentication
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| POST | `/api/auth/register` | Public | Register doctor or patient |
| POST | `/api/auth/login` | Public | Login and get JWT token |
| GET | `/api/auth/me` | Private | Get current user profile |
| PUT | `/api/auth/update-password` | Private | Update password |

### 👨‍⚕️ Doctors
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| GET | `/api/doctors` | Public | Get all doctors (paginated + search) |
| GET | `/api/doctors/:id` | Public | Get doctor by ID |
| PUT | `/api/doctors/profile` | Doctor | Update doctor profile |
| POST | `/api/doctors/upload-image` | Doctor | Upload profile image |
| GET | `/api/doctors/appointments/completed` | Doctor | Get completed appointments |
| GET | `/api/doctors/stats/patients` | Doctor | Get patient statistics |
| PUT | `/api/doctors/patients/:patientId/medical-conditions` | Doctor | Update patient medical conditions |

### 🧑‍🤝‍🧑 Patients
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| GET | `/api/patients/profile` | Patient | Get patient profile |
| PUT | `/api/patients/profile` | Patient | Update personal info |
| GET | `/api/patients/medical-conditions` | Patient | View medical conditions (read-only) |
| POST | `/api/patients/upload-image` | Patient | Upload profile image |
| GET | `/api/patients/:id` | Doctor | Get patient by ID |

### 📅 Appointments
| Method | Endpoint | Access | Description |
|--------|----------|--------|-------------|
| POST | `/api/appointments` | Patient | Create appointment |
| GET | `/api/appointments/doctor` | Doctor | Get doctor's appointments |
| GET | `/api/appointments/patient` | Patient | Get patient's appointments |
| GET | `/api/appointments/:id` | Private | Get appointment by ID |
| PUT | `/api/appointments/:id/cancel` | Patient/Doctor | Cancel appointment |
| PUT | `/api/appointments/:id/confirm` | Doctor | Confirm appointment |
| PUT | `/api/appointments/:id/complete` | Doctor | Complete appointment |

---

## 🔒 Authentication

All protected routes require a Bearer token in the Authorization header:

```
Authorization: Bearer <your_jwt_token>
```

---

## 📤 Image Upload

Image uploads use `multipart/form-data` with field name `image`.

- **Max size:** 5MB
- **Allowed types:** JPEG, JPG, PNG, WebP
- **Endpoint:** `/api/doctors/upload-image` or `/api/patients/upload-image`

---

## 🔑 Role-Based Access Control

| Feature | Doctor | Patient |
|---------|--------|---------|
| Update medical conditions | ✅ | ❌ (read-only) |
| View patient profiles | ✅ | ❌ |
| Confirm/Complete appointments | ✅ | ❌ |
| Create appointments | ❌ | ✅ |
| Update personal info | ✅ | ✅ |

---

## 📊 Appointment Status Flow

```
pending → confirmed → completed
   ↓           ↓
cancelled   cancelled
```

---

## 🏥 Health Check

```
GET /health
```

Returns server status, environment, and timestamp.

---

## 🛡️ Security Features

- **Helmet** - Secure HTTP headers
- **Rate Limiting** - 100 req/15min globally, 20 req/15min for auth
- **CORS** - Configurable allowed origins
- **JWT** - Stateless authentication
- **bcrypt** - Password hashing with salt rounds 12
- **Input Validation** - express-validator on all inputs
- **Error Sanitization** - No stack traces in production

---

## 📱 Flutter Integration

All API responses follow this structure:

```json
{
  "success": true,
  "message": "Operation successful",
  "data": { ... }
}
```

Error responses:

```json
{
  "success": false,
  "message": "Error description",
  "errors": [{ "field": "email", "message": "Valid email is required" }]
}
```

---

## 📄 License

MIT © Zeyad Hassanien Abdulhafiz
