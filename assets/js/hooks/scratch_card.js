export const ScratchCard = {
  mounted() { 
    this.scratchArea = document.getElementById("scratch-area");
    if (!this.scratchArea) return;

    this.scratchArea.style.touchAction = "none";
    this.context = this.scratchArea.getContext("2d");
    this.scratchAreaWidth = this.scratchArea.width;
    this.scratchAreaHeight = this.scratchArea.height;

    this.isScrathing = false;
    this.gameEnded = false;
    this.canScratch = false;
    this.card_id = null;

    this.initializeCard();
    this.setupEventListeners();

    this.handleEvent("scratch-card", ({card_id}) => {
      this.card_id = card_id;
      this.startGame();
    })

    this.handleEvent("clear-card", () => {
      this.resetCard();
    })
  },

  startGame() {
    this.gameEnded = false;
    this.canScratch = true;
    this.resetCard();
  },

  endGame() {
    if (this.gameEnded) return;
    this.gameEnded = true;
    this.canScratch = false;
    
    this.scratchArea.style.opacity = "0";
    
    this.pushEvent("scratch-completed", {card_id: this.card_id});
  },

  initializeCard() {
    this.context.fillStyle = "#aaa9bc";
    this.context.fillRect(0, 0, this.scratchAreaWidth, this.scratchAreaHeight);
  },

  resetCard() {
    this.context.globalCompositeOperation = "source-over";
    this.context.fillStyle = "#aaa9bc";
    this.context.fillRect(0, 0, this.scratchAreaWidth, this.scratchAreaHeight);
    this.scratchArea.style.opacity = "1";
  },

  scratchPoint(x, y) {
    this.context.globalCompositeOperation = "destination-out"
    this.context.beginPath();
    this.context.arc(x, y, 30, 0, 2*Math.PI);
    this.context.fill();
  },

  setupEventListeners() {

    this.scratchArea.addEventListener("pointerdown", (event) => {
      if (!this.canScratch) return;
      this.isScrathing = true;
      this.scratchPoint(event.offsetX, event.offsetY);
    })

    this.scratchArea.addEventListener("pointermove", (event) => {
      if (!this.canScratch) return;
      if (this.isScrathing) {
        this.scratchPoint(event.offsetX, event.offsetY);
      }
    })

    this.scratchArea.addEventListener("pointerup", () => {
      if (!this.canScratch) return;
      this.isScrathing = false;
      this.checkScratchedPercentage();
    })

     this.scratchArea.addEventListener("pointerleave", () => {
      this.isScrathing = false;
    })
  },

  checkScratchedPercentage() {
    const imageData = this.context.getImageData(0, 0, this.scratchAreaWidth, this.scratchAreaHeight);
    const pixelData = imageData.data;

    let scratchedPixelCount = 0;
    const totalPixels = pixelData.length / 4;

    for (let i = 0; i < pixelData.length; i += 4) {
      const alpha = pixelData[i + 3];

      if (alpha === 0) {
        scratchedPixelCount++;
      }
    }

    const scratchedPercentage = (scratchedPixelCount / totalPixels) * 100;
    
    if (scratchedPercentage >= 80) {
      this.endGame();
    }
  },

};