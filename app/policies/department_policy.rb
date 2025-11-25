class DepartmentPolicy < ApplicationPolicy
  def index?
    user.admin? || user.manager?
  end

  def show?
    user.admin? || user.manager?
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
