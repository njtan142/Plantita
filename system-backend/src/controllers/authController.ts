import { Request, Response } from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { sequelize } from '../config/database';
import { env } from '../config/environment';
import { QueryTypes } from 'sequelize';

// User model interface
interface User {
  id: string;
  email: string;
  username: string;
  password_hash: string;
  first_name: string;
  last_name: string;
  role: string;
  is_active: boolean;
  email_verified: boolean;
  created_at: Date;
  updated_at: Date;
}

// Login request body interface
interface LoginRequestBody {
  email: string;
  password: string;
}

// Register request body interface
interface RegisterRequestBody {
  email: string;
  username: string;
  password: string;
  firstName: string;
  lastName: string;
}

/**
 * Login user
 * POST /api/v1/auth/login
 */
export async function login(req: Request, res: Response): Promise<void> {
  try {
    const { email, password } = req.body as LoginRequestBody;

    // Validate input
    if (!email || !password) {
      res.status(400).json({
        success: false,
        message: 'Email and password are required',
      });
      return;
    }

    // Find user by email
    const users: any[] = await sequelize.query(
      'SELECT * FROM users WHERE email = ? AND is_active = true',
      {
        replacements: [email],
        type: QueryTypes.SELECT,
      }
    );

    if (!users || users.length === 0) {
      res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
      return;
    }

    const user = users[0];

    // Verify password
    const isPasswordValid = await bcrypt.compare(password, user.password_hash);
    if (!isPasswordValid) {
      res.status(401).json({
        success: false,
        message: 'Invalid email or password',
      });
      return;
    }

    // Generate JWT token
    const token = jwt.sign(
      {
        id: user.id,
        email: user.email,
        username: user.username,
        role: user.role,
      },
      env.JWT_SECRET,
      {
        expiresIn: env.JWT_EXPIRES_IN || '7d',
      } as jwt.SignOptions
    );

    // Return success response
    res.json({
      success: true,
      data: {
        token,
        user: {
          id: user.id,
          email: user.email,
          username: user.username,
          firstName: user.first_name,
          lastName: user.last_name,
          role: user.role,
          status: 'active',
          emailVerified: user.email_verified,
          createdAt: user.created_at,
          updatedAt: user.updated_at,
        },
      },
    });
  } catch (error) {
    console.error('Login error:', error);
    res.status(500).json({
      success: false,
      message: 'An unexpected error occurred during authentication',
    });
  }
}

/**
 * Register new user
 * POST /api/v1/auth/register
 */
export async function register(req: Request, res: Response): Promise<void> {
  try {
    const { email, username, password, firstName, lastName } =
      req.body as RegisterRequestBody;

    // Validate input
    if (!email || !username || !password) {
      res.status(400).json({
        success: false,
        message: 'Email, username, and password are required',
      });
      return;
    }

    // Check if user already exists
    const existingUsers: any[] = await sequelize.query(
      'SELECT id FROM users WHERE email = ? OR username = ?',
      {
        replacements: [email, username],
        type: QueryTypes.SELECT,
      }
    );

    if (existingUsers && existingUsers.length > 0) {
      res.status(400).json({
        success: false,
        message: 'User with this email or username already exists',
      });
      return;
    }

    // Hash password
    const saltRounds = 10;
    const passwordHash = await bcrypt.hash(password, saltRounds);

    // Create user
    await sequelize.query(
      `INSERT INTO users (
        email, username, password_hash, first_name, last_name, role, is_active, email_verified, created_at, updated_at
      ) VALUES (?, ?, ?, ?, ?, 'user', true, false, NOW(), NOW())`,
      {
        replacements: [
          email,
          username,
          passwordHash,
          firstName || '',
          lastName || '',
        ],
        type: QueryTypes.INSERT,
      }
    );

    // Get the created user
    const createdUsers: any[] = await sequelize.query(
      'SELECT id, email, username, first_name, last_name, role, created_at, updated_at FROM users WHERE email = ?',
      {
        replacements: [email],
        type: QueryTypes.SELECT,
      }
    );

    const newUser = createdUsers[0];

    // Generate JWT token
    const token = jwt.sign(
      {
        id: newUser.id,
        email: newUser.email,
        username: newUser.username,
        role: newUser.role,
      },
      env.JWT_SECRET,
      {
        expiresIn: env.JWT_EXPIRES_IN || '7d',
      } as jwt.SignOptions
    );

    // Return success response
    res.status(201).json({
      success: true,
      data: {
        token,
        user: {
          id: newUser.id,
          email: newUser.email,
          username: newUser.username,
          firstName: newUser.first_name,
          lastName: newUser.last_name,
          role: newUser.role,
          status: 'active',
          emailVerified: false,
          createdAt: newUser.created_at,
          updatedAt: newUser.updated_at,
        },
      },
    });
  } catch (error) {
    console.error('Registration error:', error);
    res.status(500).json({
      success: false,
      message: 'An unexpected error occurred during registration',
    });
  }
}

/**
 * Get current user
 * GET /api/v1/auth/me
 */
export async function getCurrentUser(
  req: Request,
  res: Response
): Promise<void> {
  try {
    // Get user from request (this would be set by auth middleware)
    const user = (req as any).user;

    if (!user) {
      res.status(401).json({
        success: false,
        message: 'Unauthorized',
      });
      return;
    }

    res.json({
      success: true,
      data: {
        user: {
          id: user.id,
          email: user.email,
          username: user.username,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role,
          status: user.status,
          emailVerified: user.emailVerified,
          createdAt: user.createdAt,
          updatedAt: user.updatedAt,
        },
      },
    });
  } catch (error) {
    console.error('Get current user error:', error);
    res.status(500).json({
      success: false,
      message: 'An unexpected error occurred',
    });
  }
}

/**
 * Logout user
 * POST /api/v1/auth/logout
 */
export async function logout(req: Request, res: Response): Promise<void> {
  try {
    // For JWT, we just return success since the client will handle token removal
    res.json({
      success: true,
      message: 'Logged out successfully',
    });
  } catch (error) {
    console.error('Logout error:', error);
    res.status(500).json({
      success: false,
      message: 'An unexpected error occurred during logout',
    });
  }
}
