require 'rails_helper'

RSpec.describe CallRecordingPolicy, type: :policy do
  let(:department) { create(:department) }
  let(:team) { create(:team, department: department) }

  let(:admin_user) { create(:user, :admin) }
  let(:manager_user) { create(:user, :manager) }
  let(:supervisor_user) { create(:user, role: :supervisor, team: team) }
  let(:operator_user) { create(:user, role: :operator, team: team) }
  let(:other_operator) { create(:user, :operator) }

  let(:operator_recording) { create(:call_recording, user: operator_user) }
  let(:other_recording) { create(:call_recording, user: other_operator) }

  describe '#index?' do
    it 'grants access to all roles' do
      expect(CallRecordingPolicy.new(admin_user, CallRecording).index?).to be true
      expect(CallRecordingPolicy.new(manager_user, CallRecording).index?).to be true
      expect(CallRecordingPolicy.new(supervisor_user, CallRecording).index?).to be true
      expect(CallRecordingPolicy.new(operator_user, CallRecording).index?).to be true
    end
  end

  describe '#show?' do
    it 'grants access to admins for any recording' do
      expect(CallRecordingPolicy.new(admin_user, operator_recording).show?).to be true
      expect(CallRecordingPolicy.new(admin_user, other_recording).show?).to be true
    end

    it 'grants access to managers for any recording' do
      expect(CallRecordingPolicy.new(manager_user, operator_recording).show?).to be true
      expect(CallRecordingPolicy.new(manager_user, other_recording).show?).to be true
    end

    it 'grants access to supervisors for their team recordings' do
      expect(CallRecordingPolicy.new(supervisor_user, operator_recording).show?).to be true
    end

    it 'denies access to supervisors for other team recordings' do
      expect(CallRecordingPolicy.new(supervisor_user, other_recording).show?).to be false
    end

    it 'grants access to operators for their own recordings' do
      expect(CallRecordingPolicy.new(operator_user, operator_recording).show?).to be true
    end

    it 'denies access to operators for other recordings' do
      expect(CallRecordingPolicy.new(operator_user, other_recording).show?).to be false
    end
  end

  describe '#create?' do
    it 'grants access to all roles' do
      expect(CallRecordingPolicy.new(admin_user, CallRecording).create?).to be true
      expect(CallRecordingPolicy.new(manager_user, CallRecording).create?).to be true
      expect(CallRecordingPolicy.new(supervisor_user, CallRecording).create?).to be true
      expect(CallRecordingPolicy.new(operator_user, CallRecording).create?).to be true
    end
  end

  describe '#update?' do
    it 'grants access to admins' do
      expect(CallRecordingPolicy.new(admin_user, operator_recording).update?).to be true
    end

    it 'grants access to managers' do
      expect(CallRecordingPolicy.new(manager_user, operator_recording).update?).to be true
    end

    it 'denies access to supervisors' do
      expect(CallRecordingPolicy.new(supervisor_user, operator_recording).update?).to be false
    end

    it 'denies access to operators' do
      expect(CallRecordingPolicy.new(operator_user, operator_recording).update?).to be false
    end
  end

  describe '#destroy?' do
    it 'grants access to admins' do
      expect(CallRecordingPolicy.new(admin_user, operator_recording).destroy?).to be true
    end

    it 'grants access to managers' do
      expect(CallRecordingPolicy.new(manager_user, operator_recording).destroy?).to be true
    end

    it 'denies access to supervisors' do
      expect(CallRecordingPolicy.new(supervisor_user, operator_recording).destroy?).to be false
    end

    it 'denies access to operators' do
      expect(CallRecordingPolicy.new(operator_user, operator_recording).destroy?).to be false
    end
  end
end
