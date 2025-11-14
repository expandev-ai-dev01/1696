import { Request, Response, NextFunction } from 'express';
import { AnyZodObject, ZodError } from 'zod';
import { errorResponse } from '@/utils/responses';

export const validationMiddleware =
  (schema: AnyZodObject) => async (req: Request, res: Response, next: NextFunction) => {
    try {
      await schema.parseAsync({
        body: req.body,
        query: req.query,
        params: req.params,
      });
      return next();
    } catch (error) {
      if (error instanceof ZodError) {
        const details = error.errors.map((e) => ({ path: e.path.join('.'), message: e.message }));
        return res
          .status(400)
          .json(errorResponse('Validation failed', 'VALIDATION_ERROR', details));
      }
      return res
        .status(500)
        .json(
          errorResponse('An unexpected error occurred during validation.', 'INTERNAL_SERVER_ERROR')
        );
    }
  };
