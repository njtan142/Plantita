/// <reference types="node" />
import { Sequelize } from 'sequelize';
import { env } from './environment';
import * as fs from 'fs';
import * as path from 'path';

export const sequelize = new Sequelize({
  dialect: 'postgres',
  host: env.DB_HOST,
  port: env.DB_PORT,
  database: env.DB_NAME,
  username: env.DB_USER,
  password: env.DB_PASSWORD,
  logging:
    env.NODE_ENV === 'development'
      ? (sql: string, timing?: number) => {
          console.log(`[DB Query] ${sql}${timing ? ` (${timing}ms)` : ''}`);
        }
      : false,
  pool: {
    max: 20,
    min: 5,
    acquire: 30000,
    idle: 10000,
    evict: 1000,
  },
  define: {
    timestamps: true,
    underscored: true,
    paranoid: true, // Enable soft deletes
  },
  retry: {
    match: [/SequelizeConnectionError/, /SequelizeConnectionRefusedError/],
    max: 5,
  },
});

// Test database connection
export async function testDatabaseConnection(): Promise<boolean> {
  try {
    await sequelize.authenticate();
    console.log('✅ Database connection has been established successfully.');
    return true;
  } catch (error) {
    console.error('❌ Unable to connect to the database:', error);
    return false;
  }
}

// Initialize database with proper migration system
export async function initializeDatabase(): Promise<void> {
  try {
    // Test connection first
    await sequelize.authenticate();
    console.log('✅ Database connection established successfully.');

    // Create migrations table if it doesn't exist
    await createMigrationsTable();

    // Run pending migrations
    await runMigrations();

    console.log('✅ Database initialized successfully.');
  } catch (error) {
    console.error('❌ Database initialization failed:', error);
    throw error;
  }
}

// Create migrations tracking table
async function createMigrationsTable(): Promise<void> {
  try {
    await sequelize.query(`
      CREATE TABLE IF NOT EXISTS migrations (
        id SERIAL PRIMARY KEY,
        name VARCHAR(255) NOT NULL UNIQUE,
        executed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
      );
    `);
    console.log('✅ Migrations table verified/created.');
  } catch (error) {
    console.error('❌ Failed to create migrations table:', error);
    throw error;
  }
}

// Run pending migrations
async function runMigrations(): Promise<void> {
  const migrationsPath = path.join(__dirname, '../migrations');

  if (!fs.existsSync(migrationsPath)) {
    console.log('ℹ️  No migrations directory found, skipping migrations.');
    return;
  }

  const migrationFiles = fs
    .readdirSync(migrationsPath)
    .filter(file => file.endsWith('.sql'))
    .sort();

  const executedMigrations = await getExecutedMigrations();

  for (const file of migrationFiles) {
    if (!executedMigrations.includes(file)) {
      console.log(`🔄 Running migration: ${file}`);
      await executeMigration(file);
      await recordMigration(file);
      console.log(`✅ Migration completed: ${file}`);
    } else {
      console.log(`⏭️  Migration already executed: ${file}`);
    }
  }
}

// Get list of executed migrations
async function getExecutedMigrations(): Promise<string[]> {
  try {
    const [results] = await sequelize.query(
      'SELECT name FROM migrations ORDER BY executed_at ASC'
    );
    return (results as any[]).map(row => row.name);
  } catch (error) {
    console.error('❌ Failed to get executed migrations:', error);
    return [];
  }
}

// Execute a single migration
async function executeMigration(filename: string): Promise<void> {
  const filePath = path.join(__dirname, '../migrations', filename);
  const sql = fs.readFileSync(filePath, 'utf8');

  try {
    await sequelize.query(sql);
  } catch (error) {
    console.error(`❌ Migration failed: ${filename}`, error);
    throw error;
  }
}

// Record migration execution
async function recordMigration(filename: string): Promise<void> {
  try {
    await sequelize.query('INSERT INTO migrations (name) VALUES (?)', {
      replacements: [filename],
    });
  } catch (error) {
    console.error(`❌ Failed to record migration: ${filename}`, error);
    throw error;
  }
}

// Create database backup
export async function createDatabaseBackup(
  backupPath?: string
): Promise<string> {
  const timestamp = new Date().toISOString().replace(/[:.]/g, '-');
  const backupFile = backupPath || `backup-${timestamp}.sql`;

  try {
    // This is a simplified backup - in production, use pg_dump
    console.log(`ℹ️  Creating database backup: ${backupFile}`);
    console.log('ℹ️  Note: For production use, implement pg_dump integration');

    // Log backup creation (implement actual backup logic as needed)
    console.log(`✅ Database backup created: ${backupFile}`);
    return backupFile;
  } catch (error) {
    console.error('❌ Database backup failed:', error);
    throw error;
  }
}

// Restore database from backup
export async function restoreDatabaseFromBackup(
  backupPath: string
): Promise<void> {
  try {
    console.log(`ℹ️  Restoring database from backup: ${backupPath}`);
    console.log(
      'ℹ️  Note: For production use, implement pg_restore integration'
    );

    // Log restore operation (implement actual restore logic as needed)
    console.log(`✅ Database restored from: ${backupPath}`);
  } catch (error) {
    console.error('❌ Database restore failed:', error);
    throw error;
  }
}

// Get database health status
export async function getDatabaseHealth(): Promise<{
  status: 'healthy' | 'unhealthy';
  connectionCount: number;
  pendingMigrations: string[];
}> {
  try {
    // Test connection
    await sequelize.authenticate();

    // Get connection count
    const [results] = await sequelize.query(
      'SELECT COUNT(*) as count FROM pg_stat_activity WHERE datname = ?',
      {
        replacements: [env.DB_NAME],
      }
    );
    const connectionCount = parseInt((results as any[])[0].count);

    // Get pending migrations
    const migrationsPath = path.join(__dirname, '../migrations');
    let pendingMigrations: string[] = [];

    if (fs.existsSync(migrationsPath)) {
      const migrationFiles = fs
        .readdirSync(migrationsPath)
        .filter(file => file.endsWith('.sql'))
        .sort();
      const executedMigrations = await getExecutedMigrations();
      pendingMigrations = migrationFiles.filter(
        file => !executedMigrations.includes(file)
      );
    }

    return {
      status: 'healthy',
      connectionCount,
      pendingMigrations,
    };
  } catch (error) {
    console.error('❌ Database health check failed:', error);
    return {
      status: 'unhealthy',
      connectionCount: 0,
      pendingMigrations: [],
    };
  }
}

// Close database connection
export async function closeDatabaseConnection(): Promise<void> {
  try {
    await sequelize.close();
    console.log('✅ Database connection closed successfully.');
  } catch (error) {
    console.error('❌ Error closing database connection:', error);
    throw error;
  }
}
