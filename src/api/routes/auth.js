import express from 'express';
import bcrypt from 'bcryptjs';
import jwt from 'jsonwebtoken';
import { body, validationResult } from 'express-validator';
import { logger } from '../utils/logger.js';

const router = express.Router();

// Temporary user storage (in production, use a database)
const users = [
  {
    id: 1,
    username: 'admin',
    password: '$2a$10$TEliRTMWGqqoLV0TyNFSIOi2QbYJi24Wttd3OcnkbZuA1SdsZRCl2', // 'admin123'
    role: 'admin'
  },
  {
    id: 2,
    username: 'freddy',
    password: '$2a$10$TEliRTMWGqqoLV0TyNFSIOi2QbYJi24Wttd3OcnkbZuA1SdsZRCl2', // 'admin123'
    role: 'admin'
  }
];

// Login endpoint
router.post('/login', [
  body('username').trim().isLength({ min: 3 }).withMessage('Username must be at least 3 characters'),
  body('password').isLength({ min: 6 }).withMessage('Password must be at least 6 characters')
], async (req, res, next) => {
  try {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
      return res.status(400).json({
        error: 'Validation failed',
        details: errors.array()
      });
    }

    const { username, password } = req.body;

    // Find user
    const user = users.find(u => u.username === username);
    if (!user) {
      logger.warn('Login attempt with invalid username', {
        username,
        ip: req.ip
      });
      return res.status(401).json({
        error: 'Invalid credentials'
      });
    }

    // Check password
    const isValidPassword = await bcrypt.compare(password, user.password);
    if (!isValidPassword) {
      logger.warn('Login attempt with invalid password', {
        username,
        ip: req.ip
      });
      return res.status(401).json({
        error: 'Invalid credentials'
      });
    }

    // Generate JWT token
    const token = jwt.sign(
      { 
        id: user.id, 
        username: user.username, 
        role: user.role 
      },
      process.env.JWT_SECRET || 'fallback-secret',
      { expiresIn: '24h' }
    );

    logger.info('Successful login', {
      username: user.username,
      userId: user.id,
      ip: req.ip
    });

    res.json({
      message: 'Login successful',
      token,
      user: {
        id: user.id,
        username: user.username,
        role: user.role
      }
    });

  } catch (error) {
    next(error);
  }
});

// Token validation endpoint
router.get('/validate', (req, res, next) => {
  try {
    const authHeader = req.headers.authorization;
    
    if (!authHeader) {
      return res.status(401).json({ 
        valid: false, 
        error: 'No token provided' 
      });
    }

    const token = authHeader.split(' ')[1];
    
    if (!token) {
      return res.status(401).json({ 
        valid: false, 
        error: 'Invalid token format' 
      });
    }

    const decoded = jwt.verify(token, process.env.JWT_SECRET || 'fallback-secret');
    
    res.json({
      valid: true,
      user: {
        id: decoded.id,
        username: decoded.username,
        role: decoded.role
      }
    });

  } catch (error) {
    if (error.name === 'TokenExpiredError') {
      return res.status(401).json({ 
        valid: false, 
        error: 'Token expired' 
      });
    }
    
    if (error.name === 'JsonWebTokenError') {
      return res.status(401).json({ 
        valid: false, 
        error: 'Invalid token' 
      });
    }
    
    next(error);
  }
});

// Logout endpoint (client-side token removal)
router.post('/logout', (req, res) => {
  // In a stateless JWT setup, logout is handled client-side
  // by removing the token from storage
  logger.info('User logged out', {
    ip: req.ip
  });
  
  res.json({
    message: 'Logged out successfully'
  });
});

export default router;
