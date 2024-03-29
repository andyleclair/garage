// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix"
import { LiveSocket } from "phoenix_live_view"
import topbar from "../vendor/topbar"
import live_select from "live_select"
import Sortable from "../vendor/sortable"
// for uploading to S3
import Uploaders from "./uploaders"
import tag_selector from "./tag_selector"

const hooks = {
  TrixEditor: {
    mounted() {
      const element = document.querySelector("trix-editor");
      element.editor.element.addEventListener("trix-change", (_e) => {
        this.el.dispatchEvent(new Event("change", { bubbles: true }));
      });
      element.editor.element.addEventListener("trix-initialize", () => {
        element.editor.element.focus();
        var length = element.editor.getDocument().toString().length;
        window.setTimeout(() => {
          element.editor.setSelectedRange(length, length);
        }, 1);
      });
      this.handleEvent("updateContent", (data) => {
        element.editor.loadHTML(data.content || "");
      });
    },
  },
  Sortable: {
    mounted() {
      new Sortable(this.el, {
        animation: 150,
        delay: 25,
        dragClass: "drag-item",
        ghostClass: "drag-ghost",
        forceFallback: true,
        onEnd: e => {
          let params = { old: e.oldIndex, new: e.newIndex, ...e.item.dataset };
          this.pushEventTo(this.el, "reposition", params);
        }
      })
    }
  },
  ...live_select,
  ...tag_selector
}


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket('/live', Socket, {
  params: { _csrf_token: csrfToken },
  hooks: hooks,
  uploaders: Uploaders
})

// Show progress bar on live navigation and form submits
topbar.config({ barColors: { 0: "#29d" }, shadowColor: "rgba(0, 0, 0, .3)" })
window.addEventListener("phx:page-loading-start", _info => topbar.show(300))
window.addEventListener("phx:page-loading-stop", _info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket

