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
bcrypt.hash(password, saltRounds, (err, hash) => {
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
);
  `;

  console.log('SQL Command:');
  console.log(sql);
  console.log('---');

  // Execute the SQL command using Docker
  try {
    // Remove newlines and extra spaces from SQL for command line
    const cleanSql = sql.replace(/\n/g, ' ').replace(/\s+/g, ' ').trim();
    const command = `docker exec plantita-postgres psql -U postgres -d plantita_social_dev -c "${cleanSql}"`;
    console.log('Executing command:', command);
    const result = execSync(command, { stdio: 'inherit' });
    console.log('Command result:', result);
    console.log('\n✅ Admin user created successfully!');
    console.log('\nLogin credentials:');
    console.log('- Email:', email);
    console.log('- Password:', password);
  } catch (error) {
    console.error('❌ Error creating admin user:', error.message);
    console.error('Error stack:', error.stack);
    process.exit(1);
  }
});