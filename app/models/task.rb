require "observer"

class Task < ApplicationRecord
    include Observable

    belongs_to :board
    belongs_to :user, optional: true

    # Use positional arguments for enums instead of keyword arguments
    enum status: [ :not_started, :in_progress, :on_pause, :done, :cannot_be_done, :canceled ]
    enum priority: [ :low, :medium, :high, :urgent ]

    after_save :notify_changes
    after_destroy :notify_deletion

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
end
