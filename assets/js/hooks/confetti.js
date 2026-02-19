import "../../vendor/confetti.js";

export const Confetti = {
    mounted() {
        const jsConfetti = new JSConfetti();
        if(this.el.dataset.win? != undefined) {
            jsConfetti.addConfetti({
                confettiColors: ["#ffdb0d", "#fee243"],
                confettiRadius: 6
            });
        }
    }
}