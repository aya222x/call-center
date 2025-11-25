class CallScriptPolicy < ApplicationPolicy
  def index?
    true # All authenticated users can view call scripts
  end

  def show?
    true # All authenticated users can view a specific call script
  end

  def create?
    user.admin?
  end

  def update?
    user.admin?
  end

  def destroy?
    user.admin?
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all # All authenticated users can see all call scripts
    end
  end
end
