import * as dotenv from 'dotenv';
import { EnvironmentConfig } from '../types';

// Load environment variables from .env file
dotenv.config();

export function loadEnvironmentConfig(): EnvironmentConfig {
  // Validate required environment variables
  const requiredEnvVars = [
    'NODE_ENV',
    'PORT',
    'HOST',
    'DB_HOST',
    'DB_PORT',
    'DB_NAME',
    'DB_USER',
    'DB_PASSWORD',
    'JWT_SECRET',
    'JWT_EXPIRES_IN',
    'ALLOWED_ORIGINS',
    'UPLOAD_PATH',
    'MAX_FILE_SIZE',
    'FFMPEG_PATH',
    'SHARP_CONCURRENCY',
    'LOG_LEVEL',
  ];

  const missingVars = requiredEnvVars.filter(varName => !process.env[varName]);
  if (missingVars.length > 0) {
    throw new Error(
      `Missing required environment variables: ${missingVars.join(', ')}`
    );
  }

  return {
    NODE_ENV:
      (process.env.NODE_ENV as 'development' | 'production' | 'test') ||
      'development',
    PORT: parseInt(process.env.PORT || '3001', 10),
    HOST: process.env.HOST || 'localhost',
    DB_HOST: process.env.DB_HOST || 'localhost',
    DB_PORT: parseInt(process.env.DB_PORT || '5432', 10),
    DB_NAME: process.env.DB_NAME || 'plantita_social',
    DB_USER: process.env.DB_USER || 'postgres',
    DB_PASSWORD: process.env.DB_PASSWORD || 'password',
    JWT_SECRET: process.env.JWT_SECRET || 'fallback_secret',
    JWT_EXPIRES_IN: process.env.JWT_EXPIRES_IN || '7d',
    ALLOWED_ORIGINS: process.env.ALLOWED_ORIGINS?.split(',') || [
      'http://localhost:3000',
    ],
    UPLOAD_PATH: process.env.UPLOAD_PATH || './uploads',
    MAX_FILE_SIZE: parseInt(process.env.MAX_FILE_SIZE || '52428800', 10),
    FFMPEG_PATH: process.env.FFMPEG_PATH || '/usr/bin/ffmpeg',
    SHARP_CONCURRENCY: parseInt(process.env.SHARP_CONCURRENCY || '4', 10),
    LOG_LEVEL: process.env.LOG_LEVEL || 'info',
  };
}

// Global environment configuration instance
export const env = loadEnvironmentConfig();
