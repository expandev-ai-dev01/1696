import { Router } from 'express';
import * as loginController from '@/api/v1/external/security/login/controller';

const router = Router();

// FEATURE INTEGRATION POINT: Add external (public) feature routes here

// Security routes
router.post('/security/login', loginController.postHandler);

export default router;
