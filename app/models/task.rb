require "observer"

class Task < ApplicationRecord
  include Observable

  belongs_to :board
  belongs_to :user, optional: true

  # Use positional arguments for enums instead of keyword arguments
  enum :status, [ :not_started, :in_progress, :on_pause, :done, :cannot_be_done, :canceled ]
  enum :priority, [ :low, :medium, :high ]

  # Only notify if the changes are made by someone other than the task's user
  after_save :notify_changes, unless: :self_update?
  after_destroy :notify_deletion, unless: :self_update?

  attr_accessor :current_user # This is added to keep track of who is performing the changes

  validates :title, presence: true
  validates :description, presence: true

  # Human-readable labels
  def self.status_human_readable
    {
      "not_started" => "Not Started",
      "in_progress" => "In Progress",
      "on_pause" => "On Pause",
      "done" => "Done",
      "cannot_be_done" => "Cannot Be Done",
      "canceled" => "Canceled"
    }
  end

  # Method to get the human-readable label for the status
  def human_status
    Task.status_human_readable[status]
  end

  private

  def notify_changes
    return unless user_id_changed? || previous_changes.present?

    # Notify observers of changes (this can be refactored to ActiveSupport::Notifications)
    changed_attributes = previous_changes.except(:updated_at, :created_at)
    return if changed_attributes.empty?

    # Combine all changes into a single notification message
    change_summary = changed_attributes.keys.map { |attr| attr.to_s.humanize }.join(", ")
    notification_message = "Task was updated (#{change_summary})"

    # Notify observers with the combined message
    Rails.logger.info "Notify Changes: #{notification_message}"
    changed
    NotificationObserver.instance.update(notification_message, self)
  end

  def notify_deletion
    return unless user.present?
    notification_message = "Task '#{title}' has been deleted."

    Rails.logger.info "Notify Deletion: Task '#{title}' was deleted"
    # Notify observers of deletion (this can be refactored to ActiveSupport::Notifications)
    changed
    NotificationObserver.instance.update(notification_message, self)
  end

  def self_update?
    current_user == user
  end
end
