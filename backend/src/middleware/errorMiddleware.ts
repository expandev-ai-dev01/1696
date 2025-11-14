import { Request, Response, NextFunction } from 'express';
import { AppError } from '@/utils/errors/appError';
import { errorResponse } from '@/utils/responses';

export const errorMiddleware = (
  err: Error,
  req: Request,
  res: Response,
  // eslint-disable-next-line @typescript-eslint/no-unused-vars
  _next: NextFunction
): void => {
  console.error('Unhandled Error:', err);

  if (err instanceof AppError) {
    res.status(err.statusCode).json(errorResponse(err.message, err.code));
    return;
  }

  // Generic server error
  res.status(500).json(errorResponse('An unexpected error occurred.', 'INTERNAL_SERVER_ERROR'));
};
