class BoardPolicy < ApplicationPolicy

    def index?
      user.admin? || (user.manager? && record.team_id == user.team_id) || (user.agent? && record.team_id == user.team_id)
    end

    # Only admins and managers can create new boards
    def new?
      user.admin? || user.manager?
    end
  
    def create?
      new?
    end
  
    # Admins can see all boards, Managers and Agents only see their team's boards
    def show?
      user.admin? || (user.manager? && record.team_id == user.team_id) || (user.agent? && record.team_id == user.team_id)
    end
  
    # Only admins and managers can update boards
    def update?
      user.admin? || user.manager?
    end
  
    # Only admins can delete boards
    def destroy?
      user.admin? || (user.manager? && record.team_id == user.team_id)
    end
  
    class Scope < Scope
      def resolve
        if user.admin?
          scope.all  # Admins see all boards
        elsif user.manager?
          scope.where(team_id: user.team_id)  # Managers see boards of their own team
        elsif user.agent?
          scope.where(team_id: user.team_id)  # Agents see boards of their own team
        else
          scope.none  # No access for other roles
        end
      end
    end
end
  