class DashboardPolicy < ApplicationPolicy
  def index?
    true # All authenticated users can view dashboard
  end
end
