export const HorseRace = {
  mounted() {
    this.handleEvent("start_race", () => {
      this.clearWinner();
      this.showCountdown();
    });

    this.handleEvent("stop_race", () => {
      // Server manages the state, we just respond to visual state if needed
    });

    this.handleEvent("reset_race", () => {
      this.clearWinner();
      this.initializeHorses();

      if (this.countdownInterval) {
        clearInterval(this.countdownInterval);
        this.countdownInterval = null;
      }
      const existing = document.getElementById("race-countdown");
      if (existing) existing.remove();
    });

    this.handleEvent("horse_winner", ({ winner }) => {
      this.applyWinner(winner);
    });

    this.initializeHorses();
  },

  updated() {
    // 1. Sync horse positions from server-rendered data attributes
    if (this.el.dataset.horses) {
      try {
        const positions = JSON.parse(this.el.dataset.horses);
        this.updateHorseVisuals(positions);
      } catch (e) {
        console.error("Failed to parse horse positions", e);
      }
    }

    // 2. Sync winner state
    const winner = this.el.dataset.winner
      ? parseInt(this.el.dataset.winner, 10)
      : null;

    if (winner) {
      this.applyWinner(winner);
    } else {
      this.clearWinner();
    }

    // 3. Sync countdown timer
    const timeRemainingStr = this.el.dataset.timeRemaining;
    if (timeRemainingStr) {
      const timeRemainingMs = parseInt(timeRemainingStr, 10);
      const timerElement =
        this.el.querySelector(".race-timer") ||
        document.querySelector(".race-timer");

      if (timerElement && !isNaN(timeRemainingMs)) {
        // Convert to seconds, ensure it doesn't go below 0
        const secondsRemaining = Math.max(0, Math.ceil(timeRemainingMs / 1000));
        timerElement.textContent = this.formatTime(secondsRemaining);
      }
    }
  },

  updateHorseVisuals(positions) {
    const horseMarkers = this.el.querySelectorAll(".horse-marker");
    const horsePercentages = this.el.querySelectorAll(".horse-percentage");

    positions.forEach((pos, index) => {
      // Ensure the visual position doesn't exceed 100
      const visualPosition = Math.min(100, Math.max(0, pos));

      if (horseMarkers[index]) {
        // Adjust the positioning so the horse icon aligns nicely with the finish line at 100%
        // Using 95% as a scale factor so the horse doesn't overflow completely out of bounds.
        horseMarkers[index].style.left = `${visualPosition * 0.95}%`;
      }

      if (horsePercentages[index]) {
        const displayPercentage = Math.floor(visualPosition);
        horsePercentages[index].textContent = `${displayPercentage}%`;
      }
    });
  },

  initializeHorses() {
    const horseMarkers = this.el.querySelectorAll(".horse-marker");
    const horsePercentages = this.el.querySelectorAll(".horse-percentage");

    horseMarkers.forEach((marker) => (marker.style.left = "0%"));
    horsePercentages.forEach((percentage) => (percentage.textContent = "0%"));
  },

  applyWinner(winnerId) {
    if (!winnerId) return;

    const parsedWinnerId = parseInt(winnerId, 10);
    if (isNaN(parsedWinnerId)) return;

    // Find all lanes and highlight only the winner
    const lanes = this.el.querySelectorAll("[data-lane-index]");
    lanes.forEach((lane) => {
      const isWinner = lane.dataset.laneIndex === String(parsedWinnerId - 1);

      if (isWinner) {
        lane.classList.add("bg-red-900/20", "z-10");

        const banner = lane.querySelector(".winner-banner");
        if (banner) banner.classList.remove("hidden");

        const marker = lane.querySelector(".horse-marker");
        if (marker) {
          const horseIcon = marker.querySelector("img, .horse-icon");
          if (horseIcon) horseIcon.classList.add("animate-bounce", "scale-125");
        }
      } else {
        // Clean up other lanes just in case
        lane.classList.remove("bg-red-900/20", "z-10");

        const banner = lane.querySelector(".winner-banner");
        if (banner) banner.classList.add("hidden");

        const marker = lane.querySelector(".horse-marker");
        if (marker) {
          const horseIcon = marker.querySelector("img, .horse-icon");
          if (horseIcon)
            horseIcon.classList.remove("animate-bounce", "scale-125");
        }
      }
    });
  },

  clearWinner() {
    const lanes = this.el.querySelectorAll("[data-lane-index]");
    lanes.forEach((lane) => {
      lane.classList.remove("bg-red-900/20", "z-10");

      const banner = lane.querySelector(".winner-banner");
      if (banner) banner.classList.add("hidden");

      const marker = lane.querySelector(".horse-marker");
      if (marker) {
        const horseIcon = marker.querySelector("img, .horse-icon");
        if (horseIcon)
          horseIcon.classList.remove("animate-bounce", "scale-125");
      }
    });
  },

  showCountdown() {
    const existing = document.getElementById("race-countdown");
    if (existing) existing.remove();

    if (this.countdownInterval) {
      clearInterval(this.countdownInterval);
      this.countdownInterval = null;
    }

    const countdown = document.createElement("div");
    countdown.id = "race-countdown";

    countdown.className =
      "absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 z-50 bg-black text-red-500 text-2xl font-mono font-bold tracking-[0.2em] border border-red-500 shadow-[0_0_15px_rgba(239,68,68,0.6)] px-10 py-2 flex items-center justify-center countdown-pulse pointer-events-none";

    const container = document.getElementById("horses-container") || this.el;
    if (container) {
      container.style.position = "relative";
      container.appendChild(countdown);
    }

    let count = 3;
    countdown.textContent = count;

    this.countdownInterval = setInterval(() => {
      count--;
      if (count > 0) {
        countdown.textContent = count;
      } else {
        countdown.textContent = "GO!";
        setTimeout(() => {
          if (document.getElementById("race-countdown") === countdown) {
            countdown.remove();
          }
        }, 500);
        clearInterval(this.countdownInterval);
        this.countdownInterval = null;
      }
    }, 1000);
  },

  formatTime(totalSeconds) {
    const minutes = Math.floor(totalSeconds / 60)
      .toString()
      .padStart(2, "0");
    const seconds = (totalSeconds % 60).toString().padStart(2, "0");
    return `${minutes}:${seconds}`;
  },
};
