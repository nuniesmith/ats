import { logger } from '../utils/logger.js';

export const errorHandler = (error, req, res, next) => {
  logger.error('Unhandled error', {
    error: error.message,
    stack: error.stack,
    route: req.originalUrl,
    method: req.method,
    ip: req.ip,
    userAgent: req.get('User-Agent')
  });

  // Default error response
  let statusCode = 500;
  let message = 'Internal server error';
  let details = null;

  // Handle specific error types
  if (error.name === 'ValidationError') {
    statusCode = 400;
    message = 'Validation error';
    details = error.details || error.message;
  } else if (error.name === 'UnauthorizedError') {
    statusCode = 401;
    message = 'Unauthorized';
  } else if (error.name === 'ForbiddenError') {
    statusCode = 403;
    message = 'Forbidden';
  } else if (error.name === 'NotFoundError') {
    statusCode = 404;
    message = 'Resource not found';
  } else if (error.name === 'ConflictError') {
    statusCode = 409;
    message = 'Conflict';
  } else if (error.code === 'ENOENT') {
    statusCode = 404;
    message = 'File not found';
  } else if (error.code === 'EACCES') {
    statusCode = 403;
    message = 'Permission denied';
  }

  // Don't send stack trace in production
  const errorResponse = {
    error: message,
    status: statusCode,
    timestamp: new Date().toISOString()
  };

  if (details) {
    errorResponse.details = details;
  }

  if (process.env.NODE_ENV !== 'production') {
    errorResponse.stack = error.stack;
  }

  res.status(statusCode).json(errorResponse);
};
