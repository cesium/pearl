export const HorseRace = {
  mounted() {
    this.isPaused = false;
    this.frozenCountdown = null;
    this.justFinished = false;

    this.handleEvent("start_race", () => {
      this.clearWinner();
      this.isPaused = false;
      this.frozenCountdown = null;
      this.pauseHorseAnimations(false);
      this.showCountdown();
    });

    this.handleEvent("stop_race", () => {
      this.isPaused = true;
      this.pauseHorseAnimations(true);
      // Freeze/stop any active pre-race countdown (3..2..1..GO)
      const countdownEl = document.getElementById("race-countdown");
      if (countdownEl) {
        this.frozenCountdown = countdownEl.textContent;
      }
      if (this.countdownInterval) {
        clearInterval(this.countdownInterval);
        this.countdownInterval = null;
      }
      // Freeze the timer visually
      // Prefer the id selector (used in templates), fall back to class for compatibility
      const timerElement =
        this.el.querySelector("#race-timer, .race-timer") ||
        document.querySelector("#race-timer, .race-timer");
      if (timerElement) {
        this.frozenTime = timerElement.textContent;
      }
      // If the stop was triggered by a finish, don't reset visuals — keep winner shown.
      if (!this.justFinished) {
        // Reset horses visuals to their initial sprites/positions when manually stopped
        this.initializeHorses();
        this.applyHorseVariants();
        this.setHorsesState("rest");
        this.clearWinner();
      }
    });

    this.handleEvent("reset_race", () => {
      this.isPaused = false;
      this.frozenTime = null;
      this.frozenCountdown = null;
      this.clearWinner();
      this.initializeHorses();
      this.pauseHorseAnimations(false);

      if (this.countdownInterval) {
        clearInterval(this.countdownInterval);
        this.countdownInterval = null;
      }
      const existing = document.getElementById("race-countdown");
      if (existing) existing.remove();
    });

    this.handleEvent("horse_winner", ({ winner }) => {
      this.isPaused = true; // Stop running when there's a winner
      this.setHorsesState("rest");
      this.applyWinner(winner);
      // Ensure visuals show horses at the finish line
      try {
        let count = 0;
        if (this.el.dataset.horses) {
          const parsed = JSON.parse(this.el.dataset.horses);
          count = parsed.length;
        } else {
          count = this.el.querySelectorAll(".horse-marker").length;
        }
        if (count > 0) {
          const finishPositions = Array(count).fill(100);
          this.updateHorseVisuals(finishPositions);
        }
      } catch (e) {
        console.error("Failed to set finish visuals", e);
      }
      this.justFinished = true;
    });

    this.initializeHorses();
    this.applyHorseVariants();
  },

  updated() {
    if (this.isPaused) {
      if (this.frozenTime) {
        const timerElement =
          this.el.querySelector("#race-timer, .race-timer") ||
          document.querySelector("#race-timer, .race-timer");
        if (timerElement) {
          timerElement.textContent = this.frozenTime;
        }
      }
      // Preserve frozen pre-race countdown if present
      if (this.frozenCountdown) {
        const countdownEl = document.getElementById("race-countdown");
        if (countdownEl) countdownEl.textContent = this.frozenCountdown;
      }
      return; // Skip visual updates if paused
    }

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
    } else if (!this.el.dataset.winner) {
      this.clearWinner();
    }

    // 3. Sync countdown timer
    const timeRemainingStr = this.el.dataset.timeRemaining;
    if (timeRemainingStr) {
      const timeRemainingMs = parseInt(timeRemainingStr, 10);
      const timerElement =
        this.el.querySelector("#race-timer, .race-timer") ||
        document.querySelector("#race-timer, .race-timer");

      if (timerElement && !isNaN(timeRemainingMs)) {
        // Convert to seconds, ensure it doesn't go below 0
        const secondsRemaining = Math.max(0, Math.ceil(timeRemainingMs / 1000));
        timerElement.textContent = this.formatTime(secondsRemaining);
      }
    }
  },

  applyHorseVariants() {
    const markers = this.el.querySelectorAll(".horse-marker");
    const variants = [
      "horse-variant-gold",
      "horse-variant-brown",
      "horse-variant-grey",
      "horse-variant-black",
    ];

    markers.forEach((marker, index) => {
      const icon = marker.querySelector(".horse-icon");
      if (icon) {
        // Clear previous variants
        variants.forEach((v) => icon.classList.remove(v));
        // Apply variant in loop
        icon.classList.add(variants[index % variants.length]);
      }
    });
  },

  setHorsesState(state) {
    const markers = this.el.querySelectorAll(".horse-marker");
    markers.forEach((marker) => {
      const icon = marker.querySelector(".horse-icon");
      if (icon) {
        if (state === "run") {
          icon.classList.remove("horse-rest");
          icon.classList.add("horse-run");
          marker.classList.add("racing");
        } else {
          icon.classList.remove("horse-run");
          icon.classList.add("horse-rest");
          marker.classList.remove("racing");
        }
      }
    });
  },

  pauseHorseAnimations(shouldPause) {
    const markers = this.el.querySelectorAll(".horse-marker");
    markers.forEach((marker) => {
      const icon = marker.querySelector(".horse-icon");
      if (icon) {
        if (shouldPause) {
          icon.classList.add("paused");
        } else {
          icon.classList.remove("paused");
        }
      }
    });
  },

  updateHorseVisuals(positions) {
    const horseMarkers = this.el.querySelectorAll(".horse-marker");
    const horsePercentages = this.el.querySelectorAll(".horse-percentage");

    positions.forEach((pos, index) => {
      // Ensure the visual position doesn't exceed 100
      const visualPosition = Math.min(100, Math.max(0, pos));

      if (horseMarkers[index]) {
        // Adjust the positioning so the horse icon aligns nicely with the finish line at 100%
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

    horseMarkers.forEach((marker) => {
      marker.style.left = "0%";
      marker.classList.remove("racing");
    });

    horsePercentages.forEach((percentage) => (percentage.textContent = "0%"));
    this.setHorsesState("rest");
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
          const horseIcon = marker.querySelector(".horse-icon");
          if (horseIcon) {
            horseIcon.classList.add("scale-125");
          }
        }
      } else {
        // Clean up other lanes just in case
        lane.classList.remove("bg-red-900/20", "z-10");

        const banner = lane.querySelector(".winner-banner");
        if (banner) banner.classList.add("hidden");

        const marker = lane.querySelector(".horse-marker");
        if (marker) {
          const horseIcon = marker.querySelector(".horse-icon");
          if (horseIcon) {
            horseIcon.classList.remove("scale-125");
          }
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
        const horseIcon = marker.querySelector(".horse-icon");
        if (horseIcon) {
          horseIcon.classList.remove("scale-125");
        }
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
        this.setHorsesState("run");
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
