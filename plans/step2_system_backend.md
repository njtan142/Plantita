# Step 2: Implement System Backend

## Overview
This step implements the core system backend that will handle all business logic, user management, media processing, and API endpoints for the social media application. The backend will serve as the central hub that all client applications (admin dashboard, user app, and uploader app) will communicate with.

## Prerequisites and Dependencies

### System Requirements
- **Node.js**: Version 18.0.0 or higher
- **PostgreSQL**: Version 14.0 or higher
- **FFmpeg**: Version 4.0 or higher (for media processing)
- **Git**: Version 2.34.0 or higher

### Required Dependencies
- **Express.js**: Web framework for Node.js
- **Sequelize**: ORM for database operations
- **jsonwebtoken**: JWT authentication
- **bcryptjs**: Password hashing
- **multer**: File upload handling
- **sharp**: Image processing
- **fluent-ffmpeg**: Video processing wrapper
- **cors**: Cross-origin resource sharing
- **helmet**: Security middleware
- **dotenv**: Environment variable management
- **pg**: PostgreSQL client
- **nodemon**: Development auto-restart

### Installation Commands
```bash
# Install Node.js dependencies
npm install express sequelize jsonwebtoken bcryptjs multer sharp fluent-ffmpeg cors helmet dotenv pg

# Install development dependencies
npm install -D nodemon @types/node @types/express @types/bcryptjs @types/jsonwebtoken @types/multer @types/cors

# Install FFmpeg (system-level)
# Windows (using chocolatey)
choco install ffmpeg

# macOS (using homebrew)
brew install ffmpeg

# Ubuntu/Debian
sudo apt install ffmpeg
```

## Comprehensive Implementation Checklist

### [x] 1. Initialize System Backend Package
**Objective**: Set up the basic Node.js project structure and configuration

**Detailed Instructions**:
1. Create `system-backend/package.json` with proper dependencies
2. Set up `system-backend/.env` for environment variables
3. Create basic directory structure (`src/`, `config/`, `models/`, `controllers/`, `routes/`, `middleware/`, `utils/`)
4. Configure TypeScript and ESLint
5. Set up development scripts

**Expected Files**:
```
system-backend/
├── package.json
├── tsconfig.json
├── .env
├── .env.example
├── .eslintrc.js
└── src/
    ├── index.ts
    ├── app.ts
    ├── config/
    │   ├── database.ts
    │   └── environment.ts
    └── types/
        └── index.ts
```

**Verification Steps**:
- Run `npm install` successfully
- Verify TypeScript compilation works
- Check that environment variables are loaded correctly

### [x] 2. Set up Express.js Server
**Objective**: Configure the main Express.js application with middleware and basic routing

**Detailed Instructions**:
1. Create main application entry point (`src/app.ts`)
2. Configure Express middleware (CORS, JSON parsing, security headers)
3. Set up error handling middleware
4. Configure request logging
5. Set up basic health check endpoint
6. Configure development vs production settings

**Key Middleware Configuration**:
```typescript
// Essential middleware setup
app.use(cors({
  origin: process.env.ALLOWED_ORIGINS?.split(','),
  credentials: true
}));
app.use(express.json({ limit: '50mb' }));
app.use(express.urlencoded({ extended: true, limit: '50mb' }));
app.use(helmet());
app.use(morgan('combined'));
```

**Verification Steps**:
- Server starts without errors
- Health check endpoint responds correctly
- CORS headers are properly configured
- Error handling middleware catches and formats errors

### [x] 3. Configure Database Connection
**Objective**: Establish PostgreSQL connection using Sequelize ORM

**Detailed Instructions**:
1. Set up Sequelize configuration for PostgreSQL
2. Configure connection pooling and optimization
3. Set up database migration system
4. Create database initialization scripts
5. Configure database logging and error handling
6. Set up database backup and recovery procedures

**Database Configuration**:
```typescript
// Sequelize configuration
**Results**:
✅ Database connectivity test completed successfully
✅ PostgreSQL container started using Docker
✅ Initial migration (001_initial_schema.sql) executed successfully
✅ All required tables created: users, posts, media_files, post_media, likes, comments
✅ Indexes and triggers created for optimal performance
✅ Migration tracking system initialized
### [x] 4. Server Verification and Testing
**Objective**: Verify that the system backend starts successfully and all endpoints work correctly

**Verification Results**:
✅ Server starts successfully on port 3001
✅ Database connection established without errors
✅ Health endpoints responding correctly:
  - `GET /health` returns: `{"status":"ok","timestamp":"2025-08-21T13:35:13.378Z","environment":"development","version":"1.0.0"}`
  - `GET /health/database` returns: `{"status":"healthy","timestamp":"2025-08-21T13:35:33.165Z","database":{"connectionCount":1,"pendingMigrations":[]}}`
✅ All security middleware functioning properly (CORS, Helmet, security headers)
✅ Request logging working correctly
✅ Server running in development environment

**Test Commands**:
```bash
# Test server startup
cd system-backend && npm run dev

# Test health endpoints
curl http://localhost:3001/health
curl http://localhost:3001/health/database

# Test with headers
curl -I http://localhost:3001/health
```

**Expected Server Output**:
```
✅ Database connection established successfully.
✅ Migrations table verified/created.
✅ Database initialized successfully.
🚀 System Backend Server is running on http://localhost:3001
📝 Environment: development
🏥 Health check: http://localhost:3001/health
🔌 API endpoint: http://localhost:3001/api
```
const sequelize = new Sequelize({
