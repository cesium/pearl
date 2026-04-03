import "../../vendor/confetti.js";

export const Confetti = {
    mounted() {
        const jsConfetti = new JSConfetti();
        if(this.el.dataset.is_win != undefined) {
            jsConfetti.addConfetti({
                confettiColors: ["#ff0000", "#00ff00", "#0000ff", "#ffff00", "#ff00ff", "#00ffff", "#ff6600", "#ff0099"],
                confettiRadius: 6
            });
        }
    }
}