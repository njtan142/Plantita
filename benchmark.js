const iters = 1000000;

console.log(`Running benchmark with ${iters} iterations...`);

const startInside = performance.now();
for (let i = 0; i < iters; i++) {
  const d = new Date().toISOString();
}
const endInside = performance.now();
console.log(`Time with new Date().toISOString() INSIDE loop: ${(endInside - startInside).toFixed(2)} ms`);

const startOutside = performance.now();
const d2 = new Date().toISOString();
for (let i = 0; i < iters; i++) {
  const d = d2;
}
const endOutside = performance.now();
console.log(`Time with new Date().toISOString() OUTSIDE loop: ${(endOutside - startOutside).toFixed(2)} ms`);
