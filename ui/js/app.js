function main() {
    return {
        show: false,
        minleft: 60,

        listen() {
            window.addEventListener('message', ({ data }) => {
                if (data.type === 'show') this.show = data.show;
                if (data.type === 'update') this.minleft = data.minleft;
            });
        }
    }
}