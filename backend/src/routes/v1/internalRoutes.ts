import { Router } from 'express';
import { authMiddleware } from '@/middleware/authMiddleware';

const router = Router();

// All internal routes are protected by the auth middleware
router.use(authMiddleware);

// FEATURE INTEGRATION POINT: Add internal (authenticated) feature routes here
// Example: router.use('/users', userRoutes);

export default router;
