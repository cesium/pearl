export const HorseRace = {
  mounted() {
    this.raceTimer = null;
    this.startTime = null;
    this.isRunning = false;
    this.endTime = null;
    this.horses = [];
    this.horseSpeeds = [];
    this.lastUpdateTime = 0;
    this.raceFinished = false;
    this.firstWinner = null;
    this.winnerAnnounced = false;
    this.isResetting = false;

    this.componentId = this.el.getAttribute("id");

    this.handleEvent("start_race", (data) => {
      this.startRace(data);
    });

    this.handleEvent("stop_race", () => {
      this.stopRace();
    });

    this.handleEvent("reset_race", () => {
      this.isRunning = false;
      this.isResetting = true;
      this.raceFinished = true;

      if (this.raceTimer) {
        clearInterval(this.raceTimer);
        this.raceTimer = null;
      }

      this.startTime = null;
      this.endTime = null;
      this.firstWinner = null;
      this.winnerAnnounced = false;
      this.horses.fill(0);

      const announcement = document.getElementById("winner-announcement");
      if (announcement) announcement.remove();

      const countdown = document.getElementById("race-countdown");
      if (countdown) countdown.remove();

      const timerElement = document.getElementById("race-timer");
      const gameElement = document.getElementById("horse-race-game");
      if (gameElement && timerElement) {
        const totalTime =
          parseInt(gameElement.getAttribute("data-duration")) || 120;
        timerElement.textContent = this.formatTime(totalTime);
      }

      const resetHorses = () => {
        const horseMarkers = document.querySelectorAll(".horse-marker");
        const horsePercentages = document.querySelectorAll(".horse-percentage");

        horseMarkers.forEach((marker, index) => {
          const currentLeft = window.getComputedStyle(marker).left;

          marker.style = "";
          marker.removeAttribute("style");

          marker.style.setProperty("left", "0px", "important");
          marker.style.setProperty("position", "absolute", "important");
          marker.style.setProperty("top", "0px", "important");
          marker.style.setProperty("height", "100%", "important");
          marker.style.setProperty("width", "3rem", "important");
          marker.style.setProperty("display", "flex", "important");
          marker.style.setProperty("align-items", "center", "important");
          marker.style.setProperty("justify-content", "center", "important");
          marker.style.setProperty(
            "transition",
            "left 0.1s linear",
            "important",
          );
          marker.style.setProperty("z-index", "10", "important");

          marker.setAttribute("data-position", "0");
          marker.classList.remove("racing", "near-finish");

          const horseIcon = marker.querySelector(".horse-icon");
          if (horseIcon) {
            horseIcon.classList.remove(
              "animate-bounce",
              "scale-125",
              "brightness-125",
            );
          }

          if (horsePercentages[index]) {
            horsePercentages[index].textContent = "0%";
          }

          this.horses[index] = 0;
        });
      };

      resetHorses();
      setTimeout(resetHorses, 10);
      setTimeout(resetHorses, 50);
      setTimeout(resetHorses, 100);
      setTimeout(resetHorses, 150);
      setTimeout(() => {
        resetHorses();
        this.isResetting = false;
        this.raceFinished = false;
      }, 250);
    });

    this.initializeHorses();
  },

  updated() {
    if (this.isResetting && !this.isRunning) {
      return;
    }
    return;
  },

  syncHorsePositionsFromDOM() {
    const horseMarkers = document.querySelectorAll(".horse-marker");
    const horsePercentages = document.querySelectorAll(".horse-percentage");

    horseMarkers.forEach((marker, index) => {
      const dataPosition = marker.getAttribute("data-position");
      if (dataPosition !== null) {
        const position = parseFloat(dataPosition);

        marker.style.left = `${position}%`;

        const horseIcon = marker.querySelector(".horse-icon");
        if (horseIcon) {
          horseIcon.classList.remove(
            "animate-bounce",
            "scale-125",
            "brightness-125",
          );

          if (position >= 95) {
            horseIcon.classList.add("animate-bounce");
          }

          if (position === 0) {
            horseIcon.classList.remove(
              "animate-bounce",
              "scale-125",
              "brightness-125",
            );
          }
        }

        if (this.horses[index] !== undefined) {
          this.horses[index] = position;
        }

        if (horsePercentages[index]) {
          horsePercentages[index].textContent = `${Math.round(position)}%`;
        }
      }
    });
  },

  initializeHorses() {
    const horseMarkers = document.querySelectorAll(".horse-marker");
    const horsePercentages = document.querySelectorAll(".horse-percentage");

    this.horses = Array(horseMarkers.length).fill(0);
    this.horseSpeeds = this.generateHorseSpeeds(horseMarkers.length);

    horseMarkers.forEach((marker, index) => {
      marker.style.setProperty("left", "0px", "important");
      marker.setAttribute("data-position", "0");

      if (horsePercentages[index]) {
        horsePercentages[index].textContent = "0%";
      }

      const horseIcon = marker.querySelector(".horse-icon");
      if (horseIcon) {
        horseIcon.classList.remove(
          "animate-bounce",
          "scale-125",
          "brightness-125",
        );
      }
    });
  },

  generateHorseSpeeds(count) {
    const speeds = [];

    for (let i = 0; i < count; i++) {
      const baseSpeed = 0.95 + Math.random() * 0.1;
      const variation = 0.02 + Math.random() * 0.03;

      speeds.push({
        baseSpeed: baseSpeed,
        variation: variation,
      });
    }

    return speeds;
  },

  startRace(data) {
    if (this.isRunning) return;

    this.raceFinished = false;
    this.horses.fill(0);
    const horseMarkers = document.querySelectorAll(".horse-marker");
    const horsePercentages = document.querySelectorAll(".horse-percentage");

    horseMarkers.forEach((marker, index) => {
      marker.style.setProperty("left", "0px", "important");
      marker.setAttribute("data-position", "0");
      marker.classList.remove("racing", "near-finish");

      const horseIcon = marker.querySelector(".horse-icon");
      if (horseIcon) {
        horseIcon.classList.remove(
          "animate-bounce",
          "scale-125",
          "brightness-125",
        );
      }

      if (horsePercentages[index]) {
        horsePercentages[index].textContent = "0%";
      }
    });

    this.showCountdown(() => {
      this.isRunning = true;
      this.raceFinished = false;
      this.firstWinner = null;
      this.winnerAnnounced = false;
      this.startTime = Date.now();

      const durationSeconds = data?.duration || 120;
      this.endTime = this.startTime + durationSeconds * 1000;

      this.addRacingAnimations();

      this.raceTimer = setInterval(() => {
        const now = Date.now();
        const elapsed = (now - this.startTime) / 1000;
        const remaining = Math.max(0, this.endTime - now);
        const remainingSeconds = Math.floor(remaining / 1000);

        const timerElement = document.getElementById("race-timer");
        if (timerElement) {
          timerElement.textContent = this.formatTime(remainingSeconds);
        }

        this.updateHorsePositions(elapsed, durationSeconds);

        this.pushEvent("update_race", {
          elapsed: Math.floor(elapsed),
          positions: this.horses,
          js_winner: this.firstWinner,
        });

        if (remaining <= 0) {
          this.endRace();
        }
      }, 100);
    });
  },

  showCountdown(callback) {
    const existing = document.getElementById("race-countdown");
    if (existing) existing.remove();

    if (this.countdownInterval) {
      clearInterval(this.countdownInterval);
      this.countdownInterval = null;
    }

    const countdown = document.createElement("div");
    countdown.id = "race-countdown";
    countdown.className =
      "absolute top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 z-50 bg-black bg-opacity-80 text-white text-9xl font-bold rounded-full w-48 h-48 flex items-center justify-center countdown-pulse";

    this.el.style.position = "relative";
    this.el.appendChild(countdown);

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
          if (!this.raceFinished) {
            callback();
          }
        }, 500);
        clearInterval(this.countdownInterval);
        this.countdownInterval = null;
      }
    }, 1000);
  },

  addRacingAnimations() {
    const horseMarkers = document.querySelectorAll(".horse-marker");

    horseMarkers.forEach((marker) => {
      marker.classList.add("racing");
    });
  },

  removeRacingAnimations() {
    const horseMarkers = document.querySelectorAll(".horse-marker");

    horseMarkers.forEach((marker) => {
      marker.classList.remove("racing", "near-finish");
    });
  },

  updateHorsePositions(elapsed, totalDuration) {
    if (this.isResetting || !this.isRunning || this.raceFinished) {
      return;
    }

    const horseMarkers = document.querySelectorAll(".horse-marker");
    const horsePercentages = document.querySelectorAll(".horse-percentage");

    horseMarkers.forEach((marker, index) => {
      if (index >= this.horses.length) return;

      const speed = this.horseSpeeds[index];
      const timeProgress = elapsed / totalDuration;

      let basePosition = timeProgress * speed.baseSpeed * 85;
      const randomFactor = (Math.random() - 0.5) * speed.variation * 3;
      basePosition += randomFactor;

      if (timeProgress > 0.5) {
        const surgeIntensity = (timeProgress - 0.5) / 0.5;
        const surgeFactor = Math.random() * 10 * surgeIntensity;
        basePosition += surgeFactor;
      }

      if (timeProgress > 0.7) {
        const sprintIntensity = (timeProgress - 0.7) / 0.3;
        const sprintBoost = Math.random() * 8 * sprintIntensity;
        basePosition += sprintBoost;
      }

      if (timeProgress > 0.9) {
        const finalPushIntensity = (timeProgress - 0.9) / 0.1;
        const finalPush = Math.random() * 12 * finalPushIntensity;
        basePosition += finalPush;
      }

      let newPosition = Math.max(this.horses[index], basePosition);
      this.horses[index] = newPosition; // We don't cap it at 100 internally anymore, so the server can see who won
      newPosition = Math.min(newPosition, 100); // Only cap for visual rendering

      const visualPosition = newPosition;

      if (visualPosition >= 100) {
        marker.style.left = `calc(95% + 0px)`;
      } else if (visualPosition >= 95) {
        const finalProgress = (visualPosition - 95) / 5;
        const finalPosition = 92 + finalProgress * 3;
        marker.style.left = `calc(${finalPosition}% + 0px)`;
      } else {
        const startOffset = 0;
        const scaledPosition = (visualPosition / 95) * 92;
        marker.style.left = `calc(${scaledPosition}% + ${startOffset}px)`;
      }

      if (visualPosition > 80) {
        marker.classList.add("near-finish");
      } else {
        marker.classList.remove("near-finish");
      }

      const horseIcon = marker.querySelector(".horse-icon");
      if (horseIcon) {
        if (newPosition >= 100) {
          if (!this.firstWinner && !this.winnerAnnounced) {
            this.firstWinner = index + 1;
            this.winnerAnnounced = true;
            horseIcon.classList.add("animate-bounce", "scale-125");
            this.triggerFinishLinePulse();
            this.declareWinner(index + 1);
          } else if (this.firstWinner === index + 1) {
            horseIcon.classList.add("animate-bounce", "scale-125");
          } else {
            horseIcon.classList.add("animate-bounce");
            this.triggerFinishLinePulse();
          }
        } else if (newPosition >= 98) {
          horseIcon.classList.add("animate-bounce");
          this.triggerFinishLinePulse();
        } else {
          horseIcon.classList.remove("animate-bounce", "scale-125");
        }
      }

      const percentageElement = horsePercentages[index];
      if (percentageElement) {
        const displayPercentage = Math.round(newPosition);
        percentageElement.textContent = `${displayPercentage}%`;
        percentageElement.classList.add("updated");
        setTimeout(() => {
          percentageElement.classList.remove("updated");
        }, 300);
      }
    });
  },

  triggerFinishLinePulse() {
    const finishLines = document.querySelectorAll(".finish-line");
    finishLines.forEach((line) => {
      line.classList.add("finish-line-pulse");
      setTimeout(() => {
        line.classList.remove("finish-line-pulse");
      }, 1000);
    });
  },

  declareWinner(horseNumber) {
    this.createConfetti();
  },

  createConfetti() {
    for (let i = 0; i < 100; i++) {
      const confetti = document.createElement("div");
      confetti.className = "confetti-piece";
      confetti.style.left = Math.random() * 100 + "vw";
      confetti.style.animationDelay = Math.random() * 3 + "s";
      confetti.style.backgroundColor = [
        "#ffdb0d",
        "#ff6b6b",
        "#4ecdc4",
        "#45b7d1",
        "#96ceb4",
        "#ffeaa7",
      ][Math.floor(Math.random() * 6)];
      confetti.style.width = "10px";
      confetti.style.height = "10px";
      document.body.appendChild(confetti);

      setTimeout(() => {
        if (document.body.contains(confetti)) {
          confetti.remove();
        }
      }, 3000);
    }
  },

  endRace() {
    if (this.raceFinished) return;

    this.raceFinished = true;
    this.isRunning = false;

    if (this.raceTimer) {
      clearInterval(this.raceTimer);
      this.raceTimer = null;
    }

    this.stopRace();

    if (!this.winnerAnnounced) {
      let maxPosition = 0;
      let actualWinnerIndex = 0;

      this.horses.forEach((position, index) => {
        if (position > maxPosition) {
          maxPosition = position;
          actualWinnerIndex = index;
        }
      });

      this.updateFinalEmojis(actualWinnerIndex);
      this.createConfetti();
    }
  },

  updateFinalEmojis(winnerIndex) {
    const horseMarkers = document.querySelectorAll(".horse-marker");

    horseMarkers.forEach((marker, index) => {
      const horseIcon = marker.querySelector(".horse-icon");
      if (horseIcon) {
        if (index === winnerIndex) {
          horseIcon.classList.add(
            "animate-bounce",
            "scale-125",
            "brightness-125",
          );
        } else if (this.horses[index] >= 98) {
          horseIcon.classList.add("animate-bounce");
        } else {
          horseIcon.classList.remove(
            "animate-bounce",
            "scale-125",
            "brightness-125",
          );
        }
      }
    });
  },

  stopRace() {
    this.isRunning = false;
    this.raceFinished = true;

    if (this.raceTimer) {
      clearInterval(this.raceTimer);
      this.raceTimer = null;
    }

    if (this.countdownInterval) {
      clearInterval(this.countdownInterval);
      this.countdownInterval = null;
    }

    const countdown = document.getElementById("race-countdown");
    if (countdown) countdown.remove();

    for (let i = 0; i < 1000; i++) {
      clearTimeout(i);
    }

    this.removeRacingAnimations();
  },

  resetRace() {},

  formatTime(totalSeconds) {
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`;
  },

  destroyed() {
    if (this.raceTimer) {
      clearInterval(this.raceTimer);
    }
  },
};
