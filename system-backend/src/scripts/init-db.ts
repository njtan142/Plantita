#!/usr/bin/env ts-node

/**
 * Database initialization script
 * This script initializes the database with proper migrations and setup
 */

import {
  initializeDatabase,
  testDatabaseConnection,
  closeDatabaseConnection,
} from '../config/database';
import { env } from '../config/environment';

async function main() {
  console.log('🚀 Starting database initialization...');
  console.log(`📊 Environment: ${env.NODE_ENV}`);
  console.log(`🏠 Host: ${env.DB_HOST}:${env.DB_PORT}`);
  console.log(`📈 Database: ${env.DB_NAME}`);

  try {
    // Test database connection
    console.log('\n🔍 Testing database connection...');
    const isConnected = await testDatabaseConnection();

    if (!isConnected) {
      console.error(
        '❌ Failed to connect to database. Please check your connection settings.'
      );
      process.exit(1);
    }

    // Initialize database with migrations
    console.log('\n🔄 Initializing database with migrations...');
    await initializeDatabase();

    console.log('\n✅ Database initialization completed successfully!');
  } catch (error) {
    console.error('❌ Database initialization failed:', error);
    process.exit(1);
  } finally {
    // Close database connection
    try {
      await closeDatabaseConnection();
      console.log('🔌 Database connection closed.');
    } catch (error) {
      console.error('⚠️  Warning: Failed to close database connection:', error);
    }
  }
}

// Handle script execution
if (require.main === module) {
  main().catch(error => {
    console.error('💥 Script execution failed:', error);
    process.exit(1);
  });
}

export { main as initDatabase };
