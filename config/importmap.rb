# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"

# Pin jQuery from a CDN
pin "jquery", to: "https://code.jquery.com/jquery-3.6.0.min.js", preload: true

# Pin jquery-ujs from CDN or local directory
pin "jquery_ujs", to: "https://cdnjs.cloudflare.com/ajax/libs/jquery-ujs/1.2.3/rails.min.js", preload: true
pin "@rails/actioncable", to: "actioncable.esm.js"
pin_all_from "app/javascript/channels", under: "channels"
