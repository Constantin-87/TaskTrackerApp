$(document).on("turbo:load", function () {
  const flashMessage = document.getElementById("flash-message");

  if (flashMessage) {
    // Set timeout for flash message fade-out and removal
    setTimeout(() => {
      flashMessage.classList.add("fade-out");
      setTimeout(() => {
        flashMessage.remove();
      }, 500);
    }, 3000);
  }

  // Accordion Toggle
  $(".accordion-toggle")
    .off("click")
    .on("click", function () {
      var collapseTarget = $(this).attr("data-task-id");
      $(collapseTarget).slideToggle();
      $(this).toggleClass("active");
    });
});
function hideError() {
  const errorElement = document.getElementById("form_errors");
  if (errorElement) {
    errorElement.style.display = "none";
  }
}
