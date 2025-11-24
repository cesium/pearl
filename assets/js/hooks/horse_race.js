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
    
    this.componentId = this.el.getAttribute("id");

    this.handleEvent("start_race", (data) => {
      this.startRace(data);
    });

    this.handleEvent("stop_race", () => {
      this.stopRace();
    });

    this.handleEvent("reset_race", () => {
      this.resetRace();
    });
    
    this.initializeHorses();
  },

  initializeHorses() {
    const horseMarkers = document.querySelectorAll(".horse-marker");
    this.horses = Array(horseMarkers.length).fill(0);
    this.horseSpeeds = this.generateHorseSpeeds(horseMarkers.length);
  },

  generateHorseSpeeds(count) {
    const speeds = [];
    
    for (let i = 0; i < count; i++) {
      const baseSpeed = 0.95 + Math.random() * 0.10;
      const variation = 0.02 + Math.random() * 0.03;
      
      speeds.push({
        baseSpeed: baseSpeed,
        variation: variation
      });
    }
    
    return speeds;
  },

  startRace(data) {
    if (this.isRunning) return;
    
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

        this.pushEvent("update_race", { elapsed });

        if (remaining <= 0) {
          this.endRace();
        }
      }, 100);
    });
  },

  showCountdown(callback) {
    const countdown = document.createElement("div");
    countdown.id = "race-countdown";
    countdown.className = "fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 z-50 bg-black bg-opacity-80 text-white text-9xl font-bold rounded-full w-48 h-48 flex items-center justify-center countdown-pulse";
    
    document.body.appendChild(countdown);
    
    let count = 3;
    countdown.textContent = count;
    
    const countdownInterval = setInterval(() => {
      count--;
      if (count > 0) {
        countdown.textContent = count;
      } else {
        countdown.textContent = "GO!";
        setTimeout(() => {
          countdown.remove();
          callback();
        }, 500);
        clearInterval(countdownInterval);
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
      newPosition = Math.min(newPosition, 100);
      this.horses[index] = newPosition;

      const visualPosition = newPosition;
      
      if (visualPosition >= 100) {
        marker.style.left = `calc(95% + 0px)`;
      } else if (visualPosition >= 95) {
        const finalProgress = (visualPosition - 95) / 5;
        const finalPosition = 92 + (finalProgress * 3);
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
      
      const emoji = marker.querySelector("span");
      if (emoji) {
        if (newPosition >= 100) {
          if (!this.firstWinner && !this.winnerAnnounced) {
            this.firstWinner = index + 1;
            this.winnerAnnounced = true;
            emoji.textContent = "🏆";
            this.triggerFinishLinePulse();
            this.declareWinner(index + 1);
          } else if (this.firstWinner === (index + 1)) {
            emoji.textContent = "🏆";
          } else {
            emoji.textContent = "🏇";
            this.triggerFinishLinePulse();
          }
        } else if (newPosition >= 98) {
          emoji.textContent = "🏇";
          this.triggerFinishLinePulse();
        } else {
          emoji.textContent = "🐎";
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
    finishLines.forEach(line => {
      line.classList.add("finish-line-pulse");
      setTimeout(() => {
        line.classList.remove("finish-line-pulse");
      }, 1000);
    });
  },

  declareWinner(horseNumber) {
    this.showWinnerAnnouncement(horseNumber);
    this.createConfetti();
  },

  showWinnerAnnouncement(horseNumber) {
    const existingAnnouncement = document.getElementById("winner-announcement");
    if (existingAnnouncement) {
      existingAnnouncement.remove();
    }

    const announcement = document.createElement("div");
    announcement.id = "winner-announcement";
    announcement.className = "fixed top-1/2 left-1/2 transform -translate-x-1/2 -translate-y-1/2 z-50 bg-gradient-to-r from-yellow-400 to-yellow-600 text-white p-8 rounded-xl shadow-2xl winner-announcement border-4 border-yellow-300";
    announcement.innerHTML = `
      <div class="text-center">
        <div class="text-6xl mb-4">🏆</div>
        <h2 class="text-3xl font-bold mb-2">VENCEDOR!</h2>
        <p class="text-xl">Cavalo #${horseNumber} ganhou a corrida!</p>
        <div class="mt-4 text-4xl animate-bounce">🐎🏇</div>
        <p class="text-sm mt-2 opacity-80">Parabéns! 🎉</p>
      </div>
    `;

    document.body.appendChild(announcement);

    setTimeout(() => {
      if (document.getElementById("winner-announcement")) {
        announcement.remove();
      }
    }, 5000);
  },

  createConfetti() {
    for (let i = 0; i < 100; i++) {
      const confetti = document.createElement("div");
      confetti.className = "confetti-piece";
      confetti.style.left = Math.random() * 100 + "vw";
      confetti.style.animationDelay = Math.random() * 3 + "s";
      confetti.style.backgroundColor = ["#ffdb0d", "#ff6b6b", "#4ecdc4", "#45b7d1", "#96ceb4", "#ffeaa7"][Math.floor(Math.random() * 6)];
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
      this.showWinnerAnnouncement(actualWinnerIndex + 1);
      this.createConfetti();
    }
  },

  updateFinalEmojis(winnerIndex) {
    const horseMarkers = document.querySelectorAll(".horse-marker");
    
    horseMarkers.forEach((marker, index) => {
      const emoji = marker.querySelector("span");
      if (emoji) {
        if (index === winnerIndex) {
          emoji.textContent = "🏆";
        } else if (this.horses[index] >= 98) {
          emoji.textContent = "🏇";
        } else {
          emoji.textContent = "🐎";
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
    
    this.removeRacingAnimations();
  },

  resetRace() {
    this.stopRace();
    this.startTime = null;
    this.endTime = null;
    this.raceFinished = false;
    this.firstWinner = null;
    this.winnerAnnounced = false;
    this.horses.fill(0);

    const timerElement = document.getElementById("race-timer");
    const gameElement = document.getElementById("horse-race-game");
    let totalTime = 120;
    
    if (gameElement) {
      const durationData = gameElement.getAttribute("data-duration");
      if (durationData) {
        totalTime = parseInt(durationData);
      }
    }

    if (timerElement) {
      timerElement.textContent = this.formatTime(totalTime);
    }

    const progressBar = document.getElementById("race-progress-bar");
    if (progressBar) {
      progressBar.style.width = "0%";
    }

    const horseMarkers = document.querySelectorAll(".horse-marker");
    const horsePercentages = document.querySelectorAll(".horse-percentage");

    horseMarkers.forEach((marker) => {
      marker.style.left = "calc(0% + 0px)";
      marker.classList.remove("racing", "near-finish");
      const emoji = marker.querySelector("span");
      if (emoji) {
        emoji.textContent = "🐎";
      }
    });

    horsePercentages.forEach((percentage) => {
      percentage.textContent = "0%";
      percentage.classList.remove("updated");
    });

    const announcement = document.getElementById("winner-announcement");
    if (announcement) {
      announcement.remove();
    }

    const countdown = document.getElementById("race-countdown");
    if (countdown) {
      countdown.remove();
    }

    const confettiPieces = document.querySelectorAll(".confetti-piece");
    confettiPieces.forEach(piece => piece.remove());
  },

  formatTime(totalSeconds) {
    const minutes = Math.floor(totalSeconds / 60);
    const seconds = totalSeconds % 60;
    return `${String(minutes).padStart(2, "0")}:${String(seconds).padStart(2, "0")}`;
  },

  destroyed() {
    if (this.raceTimer) {
      clearInterval(this.raceTimer);
    }
  }
};