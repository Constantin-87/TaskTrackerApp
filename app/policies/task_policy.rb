class TaskPolicy < ApplicationPolicy
  def index?
    user.present? # All logged-in users can view tasks
  end

  def create?
    user.admin? || user.manager? # Only admins and managers can create tasks
  end

  def update?
    user.admin? || user.manager? # Only admins and managers can update tasks
  end

  def destroy?
    user.admin? # Only admins can delete tasks
  end
end
