import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  connect() {
    console.log("Notification controller is connected to:", this.element);
  }

  received(data) {
    console.log("Received notification data:", data);

    const notificationBox = document.getElementById('notification-box');
    if (notificationBox) {
      const newNotification = `
        <div class="alert alert-info alert-dismissible fade show" role="alert">
          ${data.message}
          <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
        </div>
      `;
      notificationBox.innerHTML += newNotification;

      // Auto-dismiss the notification after a timeout
      setTimeout(() => {
        notificationBox.removeChild(notificationBox.firstChild);
      }, 5000);
    }
  }
}
