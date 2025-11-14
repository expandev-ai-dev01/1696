import { Router } from 'express';
import v1Routes from './v1';

const router = Router();

// Version 1 Routes
router.use('/v1', v1Routes);

// Future versions can be added here
// router.use('/v2', v2Routes);

export default router;
