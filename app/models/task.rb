require 'observer'

class Task < ApplicationRecord
    include Observable

    belongs_to :board
    belongs_to :user, optional: true

    enum status: { not_started: 0, in_progress: 1, on_pause: 2, done: 3, cannot_be_done: 4, canceled: 5 }
    enum priority: { low: 0, medium: 1, high: 2, urgent: 3 }

    after_save :notify_changes
    after_destroy :notify_deletion

    private

    def notify_changes
        if user.present?
        changed_attributes = self.previous_changes.except(:updated_at, :created_at)
        if changed_attributes.any?
            changed_attributes.keys.each do |attr|
            changed
            notify_observers("Task #{attr} was updated", self)
            end
        end
        end
    end

    def notify_deletion
        if user.present?
        changed
        notify_observers("Task '#{title}' was deleted", self)
        end
    end
end
