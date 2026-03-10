import { Router } from 'express';
import {
  login,
  register,
  getCurrentUser,
  logout,
} from '../controllers/authController';
import { authenticate } from '../middleware/authMiddleware';

const router: Router = Router();

// Public routes
router.post('/login', login);
router.post('/register', register);

// Protected routes
router.get('/me', authenticate, getCurrentUser);
router.post('/logout', authenticate, logout);

export default router;
