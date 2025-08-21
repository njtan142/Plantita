/// <reference types="node" />
import { Sequelize } from 'sequelize';
import { env } from './environment';

export const sequelize = new Sequelize({
  dialect: 'postgres',
  host: env.DB_HOST,
  port: env.DB_PORT,
  database: env.DB_NAME,
  username: env.DB_USER,
  password: env.DB_PASSWORD,
  logging: env.NODE_ENV === 'development' ? console.log : false,
  pool: {
    max: 20,
    min: 5,
    acquire: 30000,
    idle: 10000,
  },
  define: {
    timestamps: true,
    underscored: true,
    paranoid: true, // Enable soft deletes
  },
});

// Test database connection
export async function testDatabaseConnection(): Promise<boolean> {
  try {
    await sequelize.authenticate();
    console.log('Database connection has been established successfully.');
    return true;
  } catch (error) {
    console.error('Unable to connect to the database:', error);
    return false;
  }
}

// Initialize database
export async function initializeDatabase(): Promise<void> {
  try {
    await sequelize.authenticate();
    console.log('Database connection established successfully.');

    // Sync database (in development only)
    if (env.NODE_ENV === 'development') {
      await sequelize.sync({ alter: true });
      console.log('Database synchronized successfully.');
    }
  } catch (error) {
    console.error('Database initialization failed:', error);
    throw error;
  }
}

// Close database connection
export async function closeDatabaseConnection(): Promise<void> {
  try {
    await sequelize.close();
    console.log('Database connection closed successfully.');
  } catch (error) {
    console.error('Error closing database connection:', error);
    throw error;
  }
}