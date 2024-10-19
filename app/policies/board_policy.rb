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
        # Managers and agents see boards for any of their teams
        scope.where(team_id: user.teams.pluck(:id))
      end
    end
  end

  private

  def user_has_access_to_team?
    user.teams.exists?(id: record.team_id)
  end
end
