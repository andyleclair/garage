export default {
  ForcePush: {
    mounted() {
      // Handle server-sent push event confirming that push is set up correctly
      this.handleEvent("subscription_created", () => {
        if (Notification.permission === "granted") {
          new Notification("Push Notifications Enabled", {
            body: "You will now receive notifications from Moped.Club",
            icon: "/favicon.ico"
          });
        }
      });

      this.el.addEventListener("click", e => {
        e.preventDefault();
        if (Notification.permission !== "denied") {
          console.log('Subscribe Push');

          navigator.serviceWorker.ready.then(registration => {
            console.log('Service Worker ready: ', registration);
            const options = { userVisibleOnly: true, applicationServerKey: this.el.dataset.key };

            registration.pushManager.subscribe(options).then((subscription) => {
              if (subscription) {
                console.log('Push subscription: ', subscription);
                this.pushEvent("push-subscription", { subscription: subscription });
              }
            }, (error) => {
              console.error('Push subscription error: ', error);
            });
          }).catch(error => {
            console.error('Service Worker registration error: ', error);
          })
        }
      });


    }
  },
  HiddenPush: {
    mounted() {
      if (Notification.permission !== "denied" && Notification.permission !== "granted") {
        this.el.style.display = "block";
      } else {
        this.el.style.display = "none";
      }
      // Handle server-sent push event confirming that push is set up correctly
      this.handleEvent("subscription_created", () => {
        liveSocket.execJS(this.el, this.el.getAttribute("data-hide"));

        if (Notification.permission === "granted") {
          new Notification("Push Notifications Enabled", {
            body: "You will now receive notifications from Moped.Club",
            icon: "/favicon.ico"
          });
        }
      });

      this.el.addEventListener("click", e => {
        e.preventDefault();
        if (Notification.permission !== "denied") {
          console.log('Subscribe Push');

          navigator.serviceWorker.ready.then(registration => {
            console.log('Service Worker ready: ', registration);
            const options = { userVisibleOnly: true, applicationServerKey: this.el.dataset.key };

            registration.pushManager.subscribe(options).then((subscription) => {
              if (subscription) {
                console.log('Push subscription: ', subscription);
                this.pushEvent("push-subscription", { subscription: subscription });
              }
            }, (error) => {
              console.error('Push subscription error: ', error);
            });
          }).catch(error => {
            console.error('Service Worker registration error: ', error);
          })
        }
      });


    }
  }
}

