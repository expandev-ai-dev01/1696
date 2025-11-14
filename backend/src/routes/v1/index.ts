import { Router } from 'express';
import externalRoutes from './externalRoutes';
import internalRoutes from './internalRoutes';

const router = Router();

// External (public) routes - e.g., /api/v1/external/auth/login
router.use('/external', externalRoutes);

// Internal (authenticated) routes - e.g., /api/v1/internal/dashboard
router.use('/internal', internalRoutes);

export default router;
