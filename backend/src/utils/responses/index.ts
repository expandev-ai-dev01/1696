interface SuccessResponse<T> {
  success: true;
  data: T;
  metadata: {
    timestamp: string;
  };
}

interface ErrorResponse {
  success: false;
  error: {
    code: string;
    message: string;
    details?: any;
  };
  timestamp: string;
}

export const successResponse = <T>(data: T): SuccessResponse<T> => ({
  success: true,
  data,
  metadata: {
    timestamp: new Date().toISOString(),
  },
});

export const errorResponse = (message: string, code: string, details?: any): ErrorResponse => ({
  success: false,
  error: {
    code,
    message,
    details,
  },
  timestamp: new Date().toISOString(),
});
