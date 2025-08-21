/// <reference types="node" />
import app from './app';
import { env } from './config/environment';
import { initializeDatabase, closeDatabaseConnection } from './config/database';

async function startServer(): Promise<void> {
  try {
    // Initialize database connection
    await initializeDatabase();

    // Start the server
    const server = app.listen(env.PORT, env.HOST, () => {
      console.log(
        `🚀 System Backend Server is running on http://${env.HOST}:${env.PORT}`
      );
      console.log(`📝 Environment: ${env.NODE_ENV}`);
      console.log(`🏥 Health check: http://${env.HOST}:${env.PORT}/health`);
      console.log(`🔌 API endpoint: http://${env.HOST}:${env.PORT}/api`);
    });

    // Graceful shutdown handling
    const gracefulShutdown = async (signal: string) => {
      console.log(`\n🛑 Received ${signal}. Starting graceful shutdown...`);

      server.close(async () => {
        console.log('📴 HTTP server closed.');

        try {
          await closeDatabaseConnection();
          console.log('✅ Database connection closed.');
          process.exit(0);
        } catch (error) {
          console.error('❌ Error during database shutdown:', error);
          process.exit(1);
        }
      });

      // Force close server after 10 seconds
      setTimeout(() => {
        console.error(
          '❌ Could not close connections in time, forcefully shutting down'
        );
        process.exit(1);
      }, 10000);
    };

    // Handle shutdown signals
    process.on('SIGTERM', () => gracefulShutdown('SIGTERM'));
    process.on('SIGINT', () => gracefulShutdown('SIGINT'));

    // Handle uncaught exceptions
    process.on('uncaughtException', error => {
      console.error('💥 Uncaught Exception:', error);
      process.exit(1);
    });

    // Handle unhandled promise rejections
    process.on('unhandledRejection', (reason, promise) => {
      console.error('💥 Unhandled Rejection at:', promise, 'reason:', reason);
      process.exit(1);
    });
  } catch (error) {
    console.error('💥 Failed to start server:', error);
    process.exit(1);
  }
}

// Start the server
startServer();
