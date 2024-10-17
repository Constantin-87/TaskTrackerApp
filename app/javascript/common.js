$(document).on('turbo:load', function() {

    // Task Accordion Toggle (for manual clicks)
    $('.accordion-toggle').off('click').on('click', function() {
        var collapseTarget = $(this).attr('data-task-id');
        $(collapseTarget).slideToggle();  // Toggle visibility on manual click
        $(this).toggleClass('active');    // Toggle active class
    });

    // Wait for the window to fully load before trying to auto-expand a task
    $(window).on('load', function() {
        var taskId = window.location.hash;
        if (taskId) {
            var collapseTarget = $(taskId);

            if (collapseTarget.length) {
                collapseTarget.slideDown();   // Expanding the collapseTarget
                $('html, body').animate({
                    scrollTop: collapseTarget.offset().top
                }, 1000);  // Smooth scroll to the task
            } else {
                console.log("Task element not found for ID: " + taskId);
            }

        } else {
            console.log("No task ID found in the URL.");
        }
    });
});

function hideError() {
    const errorElement = document.getElementById('form_errors');
    if (errorElement) {
      errorElement.style.display = 'none';
    }
  }
// // Disable Turbo if necessary on notification link clicks
// document.addEventListener('turbo:before-fetch-request', function(event) {
//     if (event.target.matches('a[data-turbo="false"]')) {
//         console.log("Turbo navigation prevented for link:", event.target.href);
//         event.preventDefault();  // Prevent Turbo from handling the link
//     }
// });
