class BoardPolicy < ApplicationPolicy
  def index?
    user.admin? || user.manager? || user.agent?
  end

  def show?
    user.admin? || user_has_access_to_team?
  end

  def new?
    user.admin? || user.manager?
  end

  def create?
    new?
  end

  def update?
    user.admin? || user.manager?
  end

  def destroy?
    user.admin?
  end

  class Scope < Scope
    def resolve
      if user.admin?
        scope.all  # Admin sees all boards
      else
        scope.where(team_id: user.team_id)  # Non-admins see boards for their team
      end
    end
  end

  private

  def user_has_access_to_team?
    (user.manager? || user.agent?) && record.team_id == user.team_id
  end
end
