class CallRecordingPolicy < ApplicationPolicy
  def index?
    true # All authenticated users can view the list
  end

  def show?
    return true if user.admin? || user.manager?
    return same_team? if user.supervisor?
    return own_recording? if user.operator?

    false
  end

  def create?
    true # All authenticated users can upload recordings
  end

  def update?
    user.admin? || user.manager?
  end

  def destroy?
    user.admin? || user.manager?
  end

  private

  def own_recording?
    record.user_id == user.id
  end

  def same_team?
    return false if user.team_id.nil? || record.user.team_id.nil?

    user.team_id == record.user.team_id
  end
end
