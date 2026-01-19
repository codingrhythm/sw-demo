// Minimal service worker for testing
self.addEventListener('install', function(e) {
    console.log('[SW] installing');
    self.skipWaiting();
});

self.addEventListener('activate', function(e) {
    console.log('[SW] activated');
});

self.addEventListener('fetch', function(e) {
    console.log('[SW] fetch');
    e.respondWith(self.fetch(e.request));
});
