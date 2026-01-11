export const SlideHeroDown = {
  mounted() {
    const el = this.el

    const show = () => {
      el.style.opacity = "1"
      el.style.pointerEvents = "auto"
    }

    const hide = () => {
      el.style.opacity = "0"
      el.style.pointerEvents = "none"
    }

    const updateVisibility = () => {
      if (window.scrollY <= 5) {
        show()
      } else {
        hide()
      }
    }

    updateVisibility()

    window.addEventListener("scroll", updateVisibility)

    el.addEventListener("click", () => {
      const offset = window.innerHeight
      window.scrollBy({
        top: offset,
        behavior: "smooth"
      })
    })

    this.destroyed = () => {
      window.removeEventListener("scroll", updateVisibility)
    }
  }
}
