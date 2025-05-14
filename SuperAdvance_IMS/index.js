window.onload = function () {
    const defaultURL = "../SuperAdvance_IMS/Items/items.html?v=3.0.9";
    const iframe = document.querySelector("iframe[name='iframe-main']");
    const links = document.querySelectorAll('.nav-link');

    // Set iframe src on load
    iframe.src = defaultURL;

    // Set active class on the matching link
    links.forEach(link => {
        if (link.getAttribute('href') === defaultURL) {
            link.classList.add('active');
        } else {
            link.classList.remove('active');
        }

        // Also handle click to change active
        link.addEventListener('click', () => {
            links.forEach(l => l.classList.remove('active'));
            link.classList.add('active');
        });
    });
};
