# Pin npm packages by running ./bin/importmap

pin "application"
pin "@hotwired/turbo-rails", to: "turbo.min.js"
pin "@hotwired/stimulus", to: "stimulus.min.js"
pin "@hotwired/stimulus-loading", to: "stimulus-loading.js"
pin_all_from "app/javascript/controllers", under: "controllers"
pin "bootstrap", to: "bootstrap.bundle.min.js"
pin "Chart.bundle", to: "Chart.bundle.js"
pin "chartkick", to: "chartkick.js"

# Remote (not vendored) on purpose: jsDelivr's "+esm" endpoint returns a single
# bundled file with every internal relative import inlined. Vendoring tom-select's
# jspm build instead 404s, because that build splits into many sibling files
# (plugins/*, contrib/*, vanilla.js, ...) reached via relative imports that only
# resolve correctly when served from jspm's own origin, not ours.
pin "tom-select", to: "https://cdn.jsdelivr.net/npm/tom-select@2.6.2/+esm"
