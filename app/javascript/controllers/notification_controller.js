import { Controller } from "@hotwired/stimulus";

export default class extends Controller {
  connect() {
    this.initializeAutoDismiss(); // Automatically dismiss notifications after 5 seconds
  }

  received(data) {
    const notificationBox = document.getElementById("notification-box");
    if (notificationBox) {
      const newNotification = document.createElement("div");
      newNotification.classList.add(
        "alert",
        "alert-info",
        "alert-dismissible",
        "fade",
        "show"
      );
      newNotification.setAttribute("role", "alert");
      newNotification.setAttribute("data-notification-id", data.id);
      newNotification.innerHTML = `
        ${data.message}
        <button type="button" class="btn-close" data-bs-dismiss="alert" aria-label="Close"></button>
      `;

      notificationBox.appendChild(newNotification);

      // Auto-dismiss after 5 seconds
      setTimeout(() => {
        if (newNotification) {
          newNotification.classList.remove("show");
          setTimeout(() => {
            newNotification.remove();
          }, 500); // Wait for fade-out
        }
      }, 5000);
    }
  }

  initializeAutoDismiss() {
    const notifications = document.querySelectorAll("#notification-box .alert");
    notifications.forEach((notification) => {
      const notificationId = notification.getAttribute("data-notification-id");

      // Auto-dismiss after 5 seconds
      setTimeout(() => {
        if (notification) {
          notification.classList.remove("show");
          setTimeout(() => {
            notification.remove();
          }, 500); // Wait for fade-out
        }
      }, 5000);
    });
  }
}
