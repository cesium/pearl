/**
 * SpeakerScroll Hook
 *
 * Handles speaker list interaction for cycling through speakers via scroll/wheel events
 * and snapping selected speakers into view within the list container.
 *
 * Features:
 * - Wheel/trackpad scrolling to cycle through speakers (throttled for smooth UX)
 * - Click on speaker to select and snap it to center of list
 * - Auto-scroll selected speaker to center when cycling
 */
export const SpeakerScroll = {
  mounted() {
    this.lastWheelTime = 0;
    this.wheelThrottle = 250;

    this.handleWheel = (e) => {
      const now = Date.now();

      if (now - this.lastWheelTime < this.wheelThrottle) {
        e.preventDefault();
        return;
      }

      this.lastWheelTime = now;
      const direction = e.deltaY > 0 ? 'next' : 'previous';

      this.pushEvent('cycle_speaker', { direction });
      e.preventDefault();
    };

    this.el.addEventListener('wheel', this.handleWheel, { passive: false });

    this.handleClick = (e) => {
      const speakerItem = e.target.closest('[id^="speaker-"]');
      if (speakerItem) {
        setTimeout(() => this.snapSelectedIntoView(), 100);
      }
    };

    this.el.addEventListener('click', this.handleClick);
  },

  updated() {
    this.snapSelectedIntoView();
  },

  destroyed() {
    if (this.handleWheel) {
      this.el.removeEventListener('wheel', this.handleWheel);
    }
    if (this.handleClick) {
      this.el.removeEventListener('click', this.handleClick);
    }
  },

  snapSelectedIntoView() {
    const selected = this.el.querySelector('.font-black\\!');

    if (selected) {
      const container = this.el;
      const containerRect = container.getBoundingClientRect();
      const selectedRect = selected.getBoundingClientRect();

      const scrollTop = container.scrollTop;
      const offsetTop = selectedRect.top - containerRect.top;
      const centerOffset = (containerRect.height - selectedRect.height) / 2;

      container.scrollTo({
        top: scrollTop + offsetTop - centerOffset,
        behavior: 'smooth',
      });
    }
  },
};
