import { application } from "controllers/application"
import { eagerLoadControllersFrom } from "@hotwired/stimulus-loading"
import "controllers/notification_controller"
eagerLoadControllersFrom("controllers", application)