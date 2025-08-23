import { Router } from 'express';
import {
  login,
  register,
  getCurrentUser,
  logout,
} from '../controllers/authController';

const router: Router = Router();

// Public routes
router.post('/login', login);
router.post('/register', register);

// Protected routes (these would typically be protected by auth middleware)
router.get('/me', getCurrentUser);
router.post('/logout', logout);

export default router;