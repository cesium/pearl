export const TabsScroll = {
    updated() {
        const current = this.el.querySelector('.current-tab');
        if (current) {
            current.scrollIntoView({ behavior: "smooth", inline: "center", block: "nearest" });
        }
    },
    mounted() {
        this.updated();
    }
}