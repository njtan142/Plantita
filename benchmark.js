const { performance } = require('perf_hooks');

// Mock data
const mockUploads = Array.from({ length: 10 }, (_, i) => ({ id: i }));

// Mock functions
async function getPendingUploads() {
  return mockUploads;
}

async function performUpload(upload) {
  // Simulate network delay
  await new Promise(resolve => setTimeout(resolve, 100));
}

async function removePendingUpload(id) {
  // Simulate local DB delay
  await new Promise(resolve => setTimeout(resolve, 10));
}

// Original implementation
async function processBackgroundUploadsSequential() {
  const pendingUploads = await getPendingUploads();
  for (const upload of pendingUploads) {
    try {
      await performUpload(upload);
      await removePendingUpload(upload.id);
    } catch (error) {}
  }
}

// Optimized implementation (Promise.all)
async function processBackgroundUploadsConcurrent() {
  const pendingUploads = await getPendingUploads();
  await Promise.all(pendingUploads.map(async (upload) => {
    try {
      await performUpload(upload);
      await removePendingUpload(upload.id);
    } catch (error) {}
  }));
}

// Concurrency-limited implementation
async function processBackgroundUploadsPool() {
  const pendingUploads = await getPendingUploads();
  const concurrencyLimit = 3;
  let i = 0;

  async function worker() {
    while (i < pendingUploads.length) {
      const upload = pendingUploads[i++];
      try {
        await performUpload(upload);
        await removePendingUpload(upload.id);
      } catch (error) {}
    }
  }

  const workers = Array.from({ length: Math.min(concurrencyLimit, pendingUploads.length) }, () => worker());
  await Promise.all(workers);
}

async function runBenchmark() {
  console.log('Running benchmark with 10 simulated uploads (100ms upload + 10ms db each)...');

  const startSeq = performance.now();
  await processBackgroundUploadsSequential();
  const endSeq = performance.now();
  console.log(`Sequential time: ${(endSeq - startSeq).toFixed(2)} ms`);

  const startConc = performance.now();
  await processBackgroundUploadsConcurrent();
  const endConc = performance.now();
  console.log(`Concurrent (Promise.all) time: ${(endConc - startConc).toFixed(2)} ms`);

  const startPool = performance.now();
  await processBackgroundUploadsPool();
  const endPool = performance.now();
  console.log(`Concurrency Pool (limit 3) time: ${(endPool - startPool).toFixed(2)} ms`);
}

runBenchmark();
