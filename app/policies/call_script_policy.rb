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
end
