const express = require('express');

const cors = require('cors');

const helmet = require('helmet');

const morgan = require('morgan');

const compression = require('compression');

const rateLimit = require('express-rate-limit');

const path = require('path');

const swaggerUi =
  require('swagger-ui-express');

require('dotenv').config();

// =========================
// CONFIG
// =========================
const connectDB =
  require('./config/db');

const swaggerSpec =
  require('./config/swagger');

// =========================
// MIDDLEWARE
// =========================
const errorHandler =
  require('./middleware/errorHandler');

const notFound =
  require('./middleware/notFound');

// =========================
// ROUTES
// =========================
const authRoutes =
  require('./routes/authRoutes');

const doctorRoutes =
  require('./routes/doctorRoutes');

const patientRoutes =
  require('./routes/patientRoutes');

const appointmentRoutes =
  require('./routes/appointmentRoutes');

// ✅ NEW CHAT ROUTES
const chatRoutes = require('./routes/chatRoutes');
// =========================
// CONNECT DATABASE
// =========================
connectDB();

const app = express();

// ======================================================
// SECURITY
// ======================================================
app.use(
  helmet({
    crossOriginResourcePolicy:
      {
        policy:
          'cross-origin',
      },
  })
);

// ======================================================
// CORS
// ======================================================
app.use(
  cors({
    origin:
      process.env
        .ALLOWED_ORIGINS
        ? process.env.ALLOWED_ORIGINS.split(
            ','
          )
        : '*',

    methods: [
      'GET',
      'POST',
      'PUT',
      'DELETE',
      'PATCH',
      'OPTIONS',
    ],

    allowedHeaders: [
      'Content-Type',
      'Authorization',
    ],

    credentials: true,
  })
);

// ======================================================
// RATE LIMITER
// ======================================================
const limiter = rateLimit({
  windowMs:
    15 * 60 * 1000,

  max: 100,

  standardHeaders: true,

  legacyHeaders: false,

  message: {
    success: false,

    message:
      'Too many requests from this IP.',
  },
});

const authLimiter =
  rateLimit({
    windowMs:
      15 * 60 * 1000,

    max: 20,

    message: {
      success: false,

      message:
        'Too many auth attempts.',
    },
  });

app.use('/api/', limiter);

app.use(
  '/api/auth/',
  authLimiter
);

// ======================================================
// BODY PARSER
// ======================================================
app.use(
  express.json({
    limit: '10mb',
  })
);

app.use(
  express.urlencoded({
    extended: true,

    limit: '10mb',
  })
);

// ======================================================
// COMPRESSION
// ======================================================
app.use(compression());

// ======================================================
// LOGGER
// ======================================================
if (
  process.env.NODE_ENV ===
  'development'
) {
  app.use(morgan('dev'));
} else {
  app.use(morgan('combined'));
}

// ======================================================
// STATIC FILES
// ======================================================
app.use(
  '/uploads',

  express.static(
    path.join(
      __dirname,
      '..',
      'uploads'
    )
  )
);

// ======================================================
// SWAGGER
// ======================================================
app.use(
  '/api/docs',

  swaggerUi.serve,

  swaggerUi.setup(
    swaggerSpec,

    {
      explorer: true,

      customCss:
        '.swagger-ui .topbar { display: none }',

      customSiteTitle:
        'Healthcare API Docs',
    }
  )
);

// ======================================================
// HEALTH CHECK
// ======================================================
app.get(
  '/health',

  (req, res) => {
    res.status(200).json({
      success: true,

      message:
        'Healthcare API is running',

      environment:
        process.env.NODE_ENV ||
        'development',

      timestamp:
        new Date().toISOString(),

      version: '1.0.0',
    });
  }
);

// ======================================================
// API ROUTES
// ======================================================
app.use(
  '/api/auth',
  authRoutes
);

app.use(
  '/api/doctors',
  doctorRoutes
);

app.use(
  '/api/patients',
  patientRoutes
);

app.use(
  '/api/appointments',
  appointmentRoutes
);

// ✅ CHAT ROUTES
app.use(
  '/api/chat',
  chatRoutes
);

app.use(cors({
  origin: '*',
  credentials: true,
}));

// ======================================================
// 404
// ======================================================
app.use(notFound);

// ======================================================
// ERROR HANDLER
// ======================================================
app.use(errorHandler);

// ======================================================
// START SERVER
// ======================================================
const PORT =
  process.env.PORT || 5000;

const server = app.listen(
  PORT,
  '0.0.0.0',
  () => {

    console.log(
      `\n🚀 Healthcare API running on port ${PORT}`
    );

    console.log(
      `📚 Docs: http://localhost:${PORT}/api/docs`
    );

    console.log(
      `❤️ Health: http://localhost:${PORT}/health\n`
    );
  }
);

// ======================================================
// UNHANDLED REJECTION
// ======================================================
process.on(
  'unhandledRejection',

  (err) => {
    console.error(
      `❌ ${err.message}`
    );

    server.close(() =>
      process.exit(1)
    );
  }
);

// ======================================================
// UNCAUGHT EXCEPTION
// ======================================================
process.on(
  'uncaughtException',

  (err) => {
    console.error(
      `❌ ${err.message}`
    );

    process.exit(1);
  }
);

// ======================================================
// GRACEFUL SHUTDOWN
// ======================================================
process.on(
  'SIGTERM',

  () => {
    console.log(
      'SIGTERM received.'
    );

    server.close(() => {
      console.log(
        'Server terminated.'
      );

      process.exit(0);
    });
  }
);
app.use(
  '/api/chat',
  chatRoutes
);

module.exports = app;