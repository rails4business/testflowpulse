# Pin npm packages by running ./bin/importmap
# config/importmap.rb
pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin "flowbite", to: "https://cdn.jsdelivr.net/npm/flowbite@3.1.2/dist/flowbite.turbo.min.js"
pin_all_from "app/javascript/controllers", under: "controllers"

pin "lexxy", to: "lexxy.js"
pin "@rails/activestorage", to: "activestorage.esm.js" # to support attachments
# pin "@rails/lexical", to: "actiontext/lexical.js", preload: true
pin "@rails/actiontext", to: "actiontext.esm.js"
