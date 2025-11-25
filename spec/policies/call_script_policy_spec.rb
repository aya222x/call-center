require 'rails_helper'

RSpec.describe CallScriptPolicy, type: :policy do
  let(:admin_user) { create(:user, :admin) }
  let(:manager_user) { create(:user, :manager) }
  let(:supervisor_user) { create(:user, :supervisor) }
  let(:operator_user) { create(:user, :operator) }
  let(:call_script) { create(:call_script) }

  describe '#index?' do
    it 'grants access to admins' do
      expect(CallScriptPolicy.new(admin_user, CallScript).index?).to be true
    end

    it 'grants access to managers' do
      expect(CallScriptPolicy.new(manager_user, CallScript).index?).to be true
    end

    it 'grants access to supervisors' do
      expect(CallScriptPolicy.new(supervisor_user, CallScript).index?).to be true
    end

    it 'grants access to operators' do
      expect(CallScriptPolicy.new(operator_user, CallScript).index?).to be true
    end
  end

  describe '#show?' do
    it 'grants access to all roles' do
      expect(CallScriptPolicy.new(admin_user, call_script).show?).to be true
      expect(CallScriptPolicy.new(manager_user, call_script).show?).to be true
      expect(CallScriptPolicy.new(supervisor_user, call_script).show?).to be true
      expect(CallScriptPolicy.new(operator_user, call_script).show?).to be true
    end
  end

  describe '#create?' do
    it 'grants access to admins' do
      expect(CallScriptPolicy.new(admin_user, CallScript).create?).to be true
    end

    it 'denies access to managers' do
      expect(CallScriptPolicy.new(manager_user, CallScript).create?).to be false
    end

    it 'denies access to supervisors' do
      expect(CallScriptPolicy.new(supervisor_user, CallScript).create?).to be false
    end

    it 'denies access to operators' do
      expect(CallScriptPolicy.new(operator_user, CallScript).create?).to be false
    end
  end

  describe '#update?' do
    it 'grants access to admins' do
      expect(CallScriptPolicy.new(admin_user, call_script).update?).to be true
    end

    it 'denies access to managers' do
      expect(CallScriptPolicy.new(manager_user, call_script).update?).to be false
    end

    it 'denies access to supervisors' do
      expect(CallScriptPolicy.new(supervisor_user, call_script).update?).to be false
    end

    it 'denies access to operators' do
      expect(CallScriptPolicy.new(operator_user, call_script).update?).to be false
    end
  end

  describe '#destroy?' do
    it 'grants access to admins' do
      expect(CallScriptPolicy.new(admin_user, call_script).destroy?).to be true
    end

    it 'denies access to all other roles' do
      expect(CallScriptPolicy.new(manager_user, call_script).destroy?).to be false
      expect(CallScriptPolicy.new(supervisor_user, call_script).destroy?).to be false
      expect(CallScriptPolicy.new(operator_user, call_script).destroy?).to be false
    end
  end
end
