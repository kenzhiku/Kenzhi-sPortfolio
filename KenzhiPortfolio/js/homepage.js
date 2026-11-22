const images = [
    "img/forest.png",
    "img/CombatSystem.png",
    "img/Horror.png",
    "img/Horror2.png",
    "img/Store.png",
    "img/Town.png",
    "img/Town2.png",
    "img/RedSwan.png"

];

let currentIndex = 0;

function changeSlide(direction) {
    const imgElement = document.getElementById("slideshow-img");

    imgElement.classList.add("fade-out");

    setTimeout(() => {
        currentIndex += direction;
        let imagesSize = images.length;

        if (currentIndex < 0) {
            currentIndex = images.length -1;
        }
        if (currentIndex >= imagesSize) {
            currentIndex = 0;
        }
        document.getElementById("slideshow-img").src = images[currentIndex]

        imgElement.classList.remove("fade-out")
    }, 200);
}