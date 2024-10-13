class BoardPolicy < ApplicationPolicy
    # Only admins and managers can create new boards
    def new?
      user.admin? || user.manager?
    end
  
    def create?
      user.admin? || user.manager?
    end
  
    # Anyone can view boards
    def show?
      true
    end
  
    # Only admins and managers can update boards
    def update?
      user.admin? || user.manager?
    end
  
    # Only admins can delete boards
    def destroy?
      user.admin?
    end
  
    class Scope < Scope
      def resolve
        scope.all
      end
    end
  end
  