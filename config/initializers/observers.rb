# config/initializers/observers.rb
Rails.application.config.to_prepare do
  Rails.logger.info "NotificationObserver initialized."
  NotificationObserver.instance # Ensures the observer instance is created
end
