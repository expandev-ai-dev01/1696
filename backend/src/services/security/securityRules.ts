import { dbRequest, ExpectedReturn } from '@/utils/database/sql';
import { AppError } from '@/utils/errors/appError';
import { comparePassword } from '@/utils/password';
import { generateToken } from '@/utils/jwt';
import { LoginBody, UserForLogin } from './securityTypes';

/**
 * @summary Handles the business logic for user login.
 * @param body The login request body containing credentials.
 * @param ipAddress The IP address of the user.
 * @param userAgent The user agent of the user's browser.
 * @returns An object containing the JWT and user information.
 */
export async function loginUser(body: LoginBody, ipAddress: string, userAgent: string) {
  const { email, password, rememberLogin } = body;

  const user = await dbRequest<UserForLogin>(
    '[security].[spUserAccountGetByEmailForLogin]',
    { email },
    ExpectedReturn.Single
  );

  if (!user) {
    await dbRequest(
      '[security].[spLoginAttemptCreate]',
      {
        idUserAccount: null,
        emailAttempt: email,
        ipAddress,
        userAgent,
        successful: 0,
        status: 'FAILURE_EMAIL',
      },
      ExpectedReturn.None
    );
    throw new AppError('Email não cadastrado no sistema', 404, 'USER_NOT_FOUND');
  }

  if (user.isLocked) {
    await dbRequest(
      '[security].[spLoginAttemptCreate]',
      {
        idUserAccount: user.idUserAccount,
        emailAttempt: email,
        ipAddress,
        userAgent,
        successful: 0,
        status: 'ACCOUNT_LOCKED',
      },
      ExpectedReturn.None
    );
    const minutes = Math.ceil((new Date(user.lockedUntil!).getTime() - Date.now()) / 60000);
    throw new AppError(
      `Sua conta está temporariamente bloqueada. Tente novamente em ${minutes} minutos.`,
      403,
      'ACCOUNT_LOCKED'
    );
  }

  const isPasswordValid = await comparePassword(password, user.passwordHash);

  if (!isPasswordValid) {
    await dbRequest(
      '[security].[spLoginAttemptCreate]',
      {
        idUserAccount: user.idUserAccount,
        emailAttempt: email,
        ipAddress,
        userAgent,
        successful: 0,
        status: 'FAILURE_PASSWORD',
      },
      ExpectedReturn.None
    );
    throw new AppError('Senha incorreta.', 401, 'INVALID_CREDENTIALS');
  }

  // On success, log the attempt
  await dbRequest(
    '[security].[spLoginAttemptCreate]',
    {
      idUserAccount: user.idUserAccount,
      emailAttempt: email,
      ipAddress,
      userAgent,
      successful: 1,
      status: 'SUCCESS',
    },
    ExpectedReturn.None
  );

  const token = generateToken({ id: user.idUserAccount }, rememberLogin);
  const decodedToken = JSON.parse(Buffer.from(token.split('.')[1], 'base64').toString());
  const expiresAt = new Date(decodedToken.exp * 1000);

  // Create a session record
  await dbRequest(
    '[security].[spUserSessionCreate]',
    {
      idUserAccount: user.idUserAccount,
      token,
      ipAddress,
      userAgent,
      dateExpires: expiresAt,
    },
    ExpectedReturn.None
  );

  // This would typically fetch more user details to return
  // For now, we return a static object for simplicity
  const userDetails = {
    id: user.idUserAccount,
    name: 'Test User', // In a real app, fetch this from the DB
    email: email,
  };

  return { token, user: userDetails };
}
