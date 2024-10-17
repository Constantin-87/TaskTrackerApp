import consumer from "channels/consumer";

consumer.subscriptions.create("NotificationChannel", {
  connected() {
    console.log("Connected to the NotificationChannel");
  },

  disconnected() {
    console.log("Disconnected from the NotificationChannel");
  },

  received(data) {
    // Ensure Stimulus is loaded and the controller is attached
    const notificationElement = document.querySelector("[data-controller='notification']");

    // Check if window.Stimulus.controllers exists
    if (window.Stimulus && window.Stimulus.controllers) {
      
      // Check if any controllers are attached to the notification element
      const notificationController = window.Stimulus.controllers.find(controller => controller.element === notificationElement);

      if (notificationController) {
        notificationController.received(data); // Call the controller's method
      } else {
        console.log("Notification controller not attached properly.");
      }
    } else {
      console.log("Stimulus or controllers not defined. Stimulus:", window.Stimulus);
    }
  }
});
