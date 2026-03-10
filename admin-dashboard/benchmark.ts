const NUM_USERS = 100000;
const NUM_SELECTED = 1000;

// Create mock data
const users = Array.from({ length: NUM_USERS }, (_, i) => ({ id: `user-${i}` }));
const selectedUsers = Array.from({ length: NUM_SELECTED }, (_, i) => `user-${Math.floor(Math.random() * NUM_USERS)}`);

console.log(`Running benchmark with ${NUM_USERS} users and ${NUM_SELECTED} selected users.\n`);

// Measure O(N) Array.includes()
console.time('Array.includes() (O(N))');
const filteredWithArray = users.filter(user => !selectedUsers.includes(user.id));
console.timeEnd('Array.includes() (O(N))');

// Measure O(1) Set.has()
console.time('Set creation');
const selectedUsersSet = new Set(selectedUsers);
console.timeEnd('Set creation');

console.time('Set.has() (O(1))');
const filteredWithSet = users.filter(user => !selectedUsersSet.has(user.id));
console.timeEnd('Set.has() (O(1))');

console.log(`\nResults: ${filteredWithArray.length === filteredWithSet.length ? 'Match ✅' : 'Mismatch ❌'}`);
