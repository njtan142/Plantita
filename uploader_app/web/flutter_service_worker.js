// Service Worker for PWA functionality
const CACHE_NAME = 'plantita-uploader-v1.0.0';
const OFFLINE_URL = '/offline.html';

// Assets to cache immediately
const CRITICAL_ASSETS = [
  '/',
  '/manifest.json',
  '/favicon.png',
  '/icons/Icon-192.png',
  '/icons/Icon-512.png',
  '/offline.html'
];

// Install event - cache critical assets
self.addEventListener('install', (event) => {
  console.log('Service Worker: Installing...');
  event.waitUntil(
    caches.open(CACHE_NAME)
      .then((cache) => {
        console.log('Service Worker: Caching critical assets...');
        return cache.addAll(CRITICAL_ASSETS);
      })
      .then(() => {
        console.log('Service Worker: Installed successfully');
        return self.skipWaiting();
      })
      .catch((error) => {
        console.error('Service Worker: Installation failed:', error);
      })
  );
});

// Activate event - clean up old caches
self.addEventListener('activate', (event) => {
  console.log('Service Worker: Activating...');
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.map((cacheName) => {
          if (cacheName !== CACHE_NAME) {
            console.log('Service Worker: Deleting old cache:', cacheName);
            return caches.delete(cacheName);
          }
        })
      );
    }).then(() => {
      console.log('Service Worker: Activated successfully');
      return self.clients.claim();
    })
  );
});

// Fetch event - serve from cache with network fallback
self.addEventListener('fetch', (event) => {
  // Skip non-GET requests and external requests
  if (event.request.method !== 'GET' ||
      !event.request.url.startsWith(self.location.origin)) {
    return;
  }

  // Handle API requests differently
  if (event.request.url.includes('/api/')) {
    event.respondWith(
      fetch(event.request)
        .then((response) => {
          // Cache successful API responses
          if (response.ok) {
            const responseClone = response.clone();
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(event.request, responseClone);
            });
          }
          return response;
        })
        .catch(() => {
          // Return cached version if available
          return caches.match(event.request);
        })
    );
    return;
  }

  // Handle static assets and pages
  event.respondWith(
    caches.match(event.request)
      .then((cachedResponse) => {
        if (cachedResponse) {
          // Return cached version and update in background
          const fetchPromise = fetch(event.request).then((networkResponse) => {
            if (networkResponse.ok) {
              caches.open(CACHE_NAME).then((cache) => {
                cache.put(event.request, networkResponse.clone());
              });
            }
            return networkResponse;
          }).catch(() => cachedResponse);

          return cachedResponse;
        }

        // Fetch from network
        return fetch(event.request)
          .then((response) => {
            // Don't cache if not a valid response
            if (!response || response.status !== 200 || response.type !== 'basic') {
              return response;
            }

            // Cache the response
            const responseToCache = response.clone();
            caches.open(CACHE_NAME).then((cache) => {
              cache.put(event.request, responseToCache);
            });

            return response;
          })
          .catch(() => {
            // Return offline page for navigation requests
            if (event.request.mode === 'navigate') {
              return caches.match(OFFLINE_URL);
            }
          });
      })
  );
});

// Background sync for failed uploads
self.addEventListener('sync', (event) => {
  console.log('Service Worker: Background sync triggered:', event.tag);

  if (event.tag === 'background-upload') {
    event.waitUntil(processBackgroundUploads());
  }
});

// Push notifications
self.addEventListener('push', (event) => {
  console.log('Service Worker: Push notification received:', event);

  if (event.data) {
    const data = event.data.json();
    const options = {
      body: data.body,
      icon: '/icons/Icon-192.png',
      badge: '/icons/Icon-192.png',
      vibrate: [100, 50, 100],
      data: {
        dateOfArrival: Date.now(),
        primaryKey: data.primaryKey
      }
    };

    event.waitUntil(
      self.registration.showNotification(data.title, options)
    );
  }
});

// Notification click handler
self.addEventListener('notificationclick', (event) => {
  console.log('Service Worker: Notification click received:', event);

  event.notification.close();

  event.waitUntil(
    clients.openWindow(event.notification.data.url || '/')
  );
});

// Background upload processing
async function processBackgroundUploads() {
  try {
    // Get pending uploads from IndexedDB or similar storage
    const pendingUploads = await getPendingUploads();
    const concurrencyLimit = 3;
    let i = 0;

    async function worker() {
      while (i < pendingUploads.length) {
        const upload = pendingUploads[i++];
        try {
          await performUpload(upload);
          await removePendingUpload(upload.id);
          console.log('Service Worker: Background upload successful:', upload.id);
        } catch (error) {
          console.error('Service Worker: Background upload failed:', upload.id, error);
          // Could implement retry logic here
        }
      }
    }

    const workers = Array.from(
      { length: Math.min(concurrencyLimit, pendingUploads.length) },
      () => worker()
    );
    await Promise.all(workers);
  } catch (error) {
    console.error('Service Worker: Background sync failed:', error);
  }
}

// Helper functions (implement based on your app's storage mechanism)
async function getPendingUploads() {
  // Implement based on your storage solution
  return [];
}

async function performUpload(upload) {
  // Implement upload logic
  throw new Error('Upload implementation needed');
}

async function removePendingUpload(id) {
  // Implement removal logic
}

// Periodic background sync (if supported)
if ('periodicSync' in self.registration) {
  self.addEventListener('periodicsync', (event) => {
    if (event.tag === 'periodic-background-sync') {
      event.waitUntil(syncContent());
    }
  });
}

async function syncContent() {
  console.log('Service Worker: Periodic background sync');
  // Implement periodic sync logic
}