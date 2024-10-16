// Configure your import map in config/importmap.rb. Read more: https://github.com/rails/importmap-rails

import "@hotwired/turbo-rails"
import "controllers"
import "jquery"
import "jquery_ujs"

console.log("jQuery version:", $.fn.jquery); // Should log the jQuery version to confirm it's loaded
console.log("jQuery UJS loaded:", typeof $.rails !== 'undefined'); // Should log true if jquery_ujs is loaded

document.addEventListener("turbo:before-fetch-request", (event) => {
  console.log("Turbo request started:", event);
});

document.addEventListener("turbo:load", (event) => {
  console.log("Turbo load event:", event);
});