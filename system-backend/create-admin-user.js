const bcrypt = require('bcryptjs');

// Admin user details
const email = 'admin@example.com';
const password = 'admin123';
const username = 'admin';
const firstName = 'Admin';
const lastName = 'User';

// Hash the password
const saltRounds = 10;
bcrypt.hash(password, saltRounds, (err, hash) => {
  if (err) {
    console.error('Error hashing password:', err);
    return;
  }
  
  console.log('Admin user details:');
  console.log('Email:', email);
  console.log('Password:', password);
  console.log('Username:', username);
  console.log('First Name:', firstName);
  console.log('Last Name:', lastName);
  console.log('Hashed Password:', hash);
  
  console.log('\nSQL to insert admin user:');
  console.log(`
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
  `);
});