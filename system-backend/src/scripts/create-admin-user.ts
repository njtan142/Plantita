#!/usr/bin/env node

/**
 * Create Admin User Script
 * This script creates an admin user in the database
 */

const { execSync } = require('child_process');
const bcrypt = require('bcryptjs');

// Get command line arguments
const args = process.argv.slice(2);
let email = 'admin@example.com';
let password = 'admin123';
let username = 'admin';
let firstName = 'Admin';
let lastName = 'User';

// Parse arguments
for (let i = 0; i < args.length; i++) {
  switch (args[i]) {
    case '--email':
    case '-e':
      email = args[i + 1];
      i++;
      break;
    case '--password':
    case '-p':
      password = args[i + 1];
      i++;
      break;
    case '--username':
    case '-u':
      username = args[i + 1];
      i++;
      break;
    case '--first-name':
    case '-f':
      firstName = args[i + 1];
      i++;
      break;
    case '--last-name':
    case '-l':
      lastName = args[i + 1];
      i++;
      break;
  }
}

console.log('Creating admin user...');
console.log('Email:', email);
console.log('Username:', username);
console.log('First Name:', firstName);
console.log('Last Name:', lastName);
console.log('---');

// Hash the password
const saltRounds = 10;
bcrypt.hash(password, saltRounds, (err: any, hash: any) => {
  if (err) {
    console.error('Error hashing password:', err);
    process.exit(1);
  }

  // Create the SQL insert statement
  const sql = `
INSERT INTO users (
  email, 
  username, 
  password_hash, 
  first_name, 
  last_name, 
  role, 
  is_active, 
  email_verified, 
  created_at, 
  updated_at
) VALUES (
  '${email}',
  '${username}',
  '${hash}',
  '${firstName}',
  '${lastName}',
  'admin',
  true,
  true,
  NOW(),
  NOW()
) ON CONFLICT (email) DO UPDATE SET
  username = EXCLUDED.username,
  password_hash = EXCLUDED.password_hash,
  first_name = EXCLUDED.first_name,
  last_name = EXCLUDED.last_name,
  role = EXCLUDED.role,
  is_active = EXCLUDED.is_active,
  email_verified = EXCLUDED.email_verified,
  updated_at = NOW();
  `;

  // Execute the SQL command using Docker
  try {
    const command = `docker exec plantita-postgres psql -U postgres -d plantita_social_dev -c "${sql}"`;
    execSync(command, { stdio: 'inherit' });
    console.log('\n✅ Admin user created/updated successfully!');
    console.log('\nLogin credentials:');
    console.log('- Email:', email);
    console.log('- Password:', password);
  } catch (error: any) {
    console.error('❌ Error creating admin user:', error.message);
    process.exit(1);
  }
});