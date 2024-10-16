// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails
import "@hotwired/turbo-rails"
import "controllers"

  
document.addEventListener("turbo:load", function() {
    console.log("Turbo load triggered");
    var accordions = document.querySelectorAll('.accordion-collapse');
    accordions.forEach(function(accordion) {
      new bootstrap.Collapse(accordion, {
        toggle: false
      });
    });
  });
  