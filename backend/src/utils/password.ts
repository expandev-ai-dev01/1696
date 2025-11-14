import bcrypt from 'bcryptjs';

const SALT_ROUNDS = 10;

/**
 * @summary Hashes a plain-text password using bcrypt.
 * @param password The plain-text password to hash.
 * @returns A promise that resolves to the hashed password.
 */
export const hashPassword = async (password: string): Promise<string> => {
  return bcrypt.hash(password, SALT_ROUNDS);
};

/**
 * @summary Compares a plain-text password with a hash.
 * @param password The plain-text password.
 * @param hash The hash to compare against.
 * @returns A promise that resolves to true if the password matches the hash, otherwise false.
 */
export const comparePassword = async (password: string, hash: string): Promise<boolean> => {
  return bcrypt.compare(password, hash);
};
