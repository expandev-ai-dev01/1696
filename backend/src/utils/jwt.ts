import jwt from 'jsonwebtoken';
import { config } from '@/config';

export interface JwtPayload {
  id: number;
  // Add other claims as needed, e.g., roles
}

/**
 * @summary Generates a JSON Web Token.
 * @param payload The data to include in the token.
 * @param rememberMe If true, uses a longer expiration time.
 * @returns The generated JWT string.
 */
export const generateToken = (payload: JwtPayload, rememberMe = false): string => {
  const expiresIn = rememberMe ? config.jwt.rememberMeExpiresIn : config.jwt.expiresIn;
  return jwt.sign(payload, config.jwt.secret, { expiresIn });
};

/**
 * @summary Verifies a JSON Web Token.
 * @param token The JWT string to verify.
 * @returns The decoded payload if the token is valid.
 * @throws An error if the token is invalid or expired.
 */
export const verifyToken = (token: string): JwtPayload => {
  try {
    return jwt.verify(token, config.jwt.secret) as JwtPayload;
  } catch (error) {
    console.error('Invalid token:', error);
    throw new Error('Invalid or expired token.');
  }
};
