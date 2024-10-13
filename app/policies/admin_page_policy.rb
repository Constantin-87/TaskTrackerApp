# app/policies/admin_page_policy.rb
class AdminPagePolicy < ApplicationPolicy
  def index?
    user.admin? # Only admins can access the admin page
  end

  def create?
    user.admin? # Only admins can create users
  end

  def update?
    user.admin? # Only admins can update users
  end

  def destroy?
    user.admin? # Only admins can delete users
  end
end
