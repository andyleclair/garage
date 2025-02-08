self.addEventListener('push', event => {
  if (event.data) {
    const payload = event.data.json();
    const title = payload.title || "Moped.Club";
    const message = payload.message || "You have a new notification";
    const url = payload.url || '/';
    const icon = '/favicon.ico'

    const options = {
      body: message,
      icon: icon,
      badge: icon,
      data: {
        url: url
      }
    }

    const promiseChain = self.registration.showNotification(title, options);

    event.waitUntil(promiseChain);
  } else {
    console.log('This push event has no data.');
  }
});

self.addEventListener('notificationclick', event => {
  console.log('Notification click Received.', event);
  clients.openWindow(event.notification.data.url);
});
