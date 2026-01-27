export const Ticker = {
  mounted() {
    const track = this.el
    const original = track.children[0]

    track.style.willChange = 'transform'
    track.style.whiteSpace = 'nowrap'

    const SPEED = 60
    let offset = 0
    let last = performance.now()
    let paused = false

    const runWidth = original.offsetWidth
    const viewportWidth = track.parentElement.offsetWidth

    let totalWidth = runWidth

    while (totalWidth < viewportWidth * 2) {
      const clone = original.cloneNode(true)
      track.appendChild(clone)
      totalWidth += runWidth
    }

    const tick = (now) => {
      const delta = (now - last) / 1000
      last = now

      if (!paused) {
        offset -= SPEED * delta

        if (offset <= -runWidth) {
          offset += runWidth
        }

        track.style.transform = `translate3d(${offset}px, 0, 0)`
      }

      this.raf = requestAnimationFrame(tick)
    }

    track.addEventListener('mouseenter', () => {
      paused = true
    })

    track.addEventListener('mouseleave', () => {
      paused = false
      last = performance.now()
    })

    this.raf = requestAnimationFrame(tick)
  },

  destroyed() {
    cancelAnimationFrame(this.raf)
  }
}
