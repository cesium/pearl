import { elapsedTime, css, flipClock, theme } from '../../vendor/flipclock';

export const LandingCountdown = {
    mounted() {
        const parent = document.getElementById("countdown-timer");
        console.log(parent);
        flipClock({
            parent,
            face: elapsedTime({
                from: new Date(parent.dataset.date),
                to: new Date,
                format: "D:hh:mm:ss"
            }),
            theme: theme({
                dividers: ':',
                css: css({
                    fontSize: '3rem'
                })
            })
        });
    }
};