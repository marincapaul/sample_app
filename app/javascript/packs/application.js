import Rails from "@rails/ujs"
import Turbolinks from "turbolinks"
import * as ActiveStorage from "@rails/activestorage"
import "channels"
import "jquery"
import "bootstrap"


document.addEventListener("turbolinks:load", () =>{
    $('[data-toggle="tooltip"').tooltip()
    $('[data-toggle="popover"').popover()
})

Rails.start()
Turbolinks.start()
ActiveStorage.start()