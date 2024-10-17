class HomePagePolicy < ApplicationPolicy
  def index?
    user.present? # All logged-in users can access the home page
  end
end
