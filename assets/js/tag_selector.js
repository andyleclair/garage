export default {
  TagSelector: {
    textInput() {
      return this.el.querySelector("input[type=text]")
    },
    addButton() {
      return this.el.querySelector("button#add-tag")
    },
    attachDomEventHandlers() {
      this.textInput().onkeydown = (event) => {
        if (event.key === "Enter") {
          event.preventDefault()
          this.addButton().click()
        }
      }
      this.addButton().onclick = (event) => {
        event.preventDefault()
        this.pushEventTo(this.el, 'add-tag', { tag: this.textInput().value })
      }
      this.el.querySelectorAll("button[data-tag]").forEach(button => {
        button.onclick = (event) => {
          event.preventDefault()
          this.pushEventTo(this.el, 'remove-tag', { tag: button.dataset.tag })
        }
      })
    },
    mounted() {
      this.attachDomEventHandlers()
    },
    updated() {
      this.attachDomEventHandlers()
    }
  }

}
