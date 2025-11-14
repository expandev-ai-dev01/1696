import { Request, Response, NextFunction } from 'express';
import { z } from 'zod';
import { loginSchema } from '@/services/security/securityTypes';
import { loginUser } from '@/services/security/securityRules';
import { successResponse } from '@/utils/responses';

const bodySchema = z.object({
  email: loginSchema.shape.email,
  password: loginSchema.shape.password,
  rememberLogin: loginSchema.shape.rememberLogin,
});

/**
 * @api {post} /external/security/login User Login
 * @apiName UserLogin
 * @apiGroup Security
 * @apiVersion 1.0.0
 *
 * @apiDescription Authenticates a user and returns a JWT.
 *
 * @apiBody {String} email User's email address.
 * @apiBody {String} password User's password.
 * @apiBody {Boolean} [rememberLogin=false] If true, the session will last for 30 days.
 *
 * @apiSuccess {Object} data The response data.
 * @apiSuccess {String} data.token The JWT for the session.
 * @apiSuccess {Object} data.user User's basic information.
 *
 * @apiError {String} UserNotFound The email was not found.
 * @apiError {String} InvalidCredentials The password was incorrect.
 * @apiError {String} AccountLocked The account is temporarily locked.
 */
export async function postHandler(req: Request, res: Response, next: NextFunction): Promise<void> {
  try {
    const validatedBody = await bodySchema.parseAsync(req.body);

    const ipAddress = (req.headers['x-forwarded-for'] as string) || req.socket.remoteAddress || '';
    const userAgent = req.headers['user-agent'] || '';

    const result = await loginUser(validatedBody, ipAddress, userAgent);

    res.status(200).json(successResponse(result));
  } catch (error) {
    next(error);
  }
}
