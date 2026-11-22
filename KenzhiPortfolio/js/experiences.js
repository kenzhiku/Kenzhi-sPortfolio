document.addEventListener('DOMContentLoaded', () => {
    const downButtons = document.querySelectorAll('.down-button');

    downButtons.forEach(button => {
        button.addEventListener('click', () => {
            
            const parentTab = button.closest('.game-development-tab');
            const categoryContainer = parentTab.querySelector('.category');

            categoryContainer.classList.toggle('expanded');
            button.classList.toggle('open');
        });
    });
});