self.addEventListener('push', event => {
  if (event.data) {
    const options = {
      icon: 'favicon.ico',
    }
    const promiseChain = self.registration.showNotification(event.data.text(), options);

    event.waitUntil(promiseChain);
  } else {
    console.log('This push event has no data.');
  }
});
