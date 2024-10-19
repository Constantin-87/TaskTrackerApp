require "observer"

class Task < ApplicationRecord
  include Observable

  belongs_to :board
  belongs_to :user, optional: true

  # Use positional arguments for enums instead of keyword arguments
  enum status: [ :not_started, :in_progress, :on_pause, :done, :cannot_be_done, :canceled ]
  enum priority: [ :low, :medium, :high, :urgent ]

  # Only notify if the changes are made by someone other than the task's user
  after_save :notify_changes, unless: :self_update?
  after_destroy :notify_deletion, unless: :self_update?

  attr_accessor :current_user # This is added to keep track of who is performing the changes

  private

  def notify_changes
    return unless user.present?

    # Notify observers of changes (this can be refactored to ActiveSupport::Notifications)
    changed_attributes = previous_changes.except(:updated_at, :created_at)
    changed_attributes.each_key do |attr|
      changed
      notify_observers("Task #{attr} was updated", self)
    end if changed_attributes.any?
  end

  def notify_deletion
    return unless user.present?

    # Notify observers of deletion (this can be refactored to ActiveSupport::Notifications)
    changed
    notify_observers("Task '#{title}' was deleted", self)
  end

  def self_update?
    current_user == user
  end
end
