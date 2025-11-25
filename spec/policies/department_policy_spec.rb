require 'rails_helper'

RSpec.describe DepartmentPolicy, type: :policy do
  let(:admin_user) { create(:user, :admin) }
  let(:manager_user) { create(:user, :manager) }
  let(:supervisor_user) { create(:user, :supervisor) }
  let(:operator_user) { create(:user, :operator) }
  let(:department) { create(:department) }

  describe '#index?' do
    it 'grants access to admins' do
      expect(DepartmentPolicy.new(admin_user, Department).index?).to be true
    end

    it 'grants access to managers' do
      expect(DepartmentPolicy.new(manager_user, Department).index?).to be true
    end

    it 'denies access to supervisors' do
      expect(DepartmentPolicy.new(supervisor_user, Department).index?).to be false
    end

    it 'denies access to operators' do
      expect(DepartmentPolicy.new(operator_user, Department).index?).to be false
    end
  end

  describe '#show?' do
    it 'grants access to admins' do
      expect(DepartmentPolicy.new(admin_user, department).show?).to be true
    end

    it 'grants access to managers' do
      expect(DepartmentPolicy.new(manager_user, department).show?).to be true
    end

    it 'denies access to supervisors' do
      expect(DepartmentPolicy.new(supervisor_user, department).show?).to be false
    end

    it 'denies access to operators' do
      expect(DepartmentPolicy.new(operator_user, department).show?).to be false
    end
  end

  describe '#create?' do
    it 'grants access to admins' do
      expect(DepartmentPolicy.new(admin_user, Department).create?).to be true
    end

    it 'denies access to managers' do
      expect(DepartmentPolicy.new(manager_user, Department).create?).to be false
    end

    it 'denies access to supervisors' do
      expect(DepartmentPolicy.new(supervisor_user, Department).create?).to be false
    end

    it 'denies access to operators' do
      expect(DepartmentPolicy.new(operator_user, Department).create?).to be false
    end
  end

  describe '#update?' do
    it 'grants access to admins' do
      expect(DepartmentPolicy.new(admin_user, department).update?).to be true
    end

    it 'denies access to managers' do
      expect(DepartmentPolicy.new(manager_user, department).update?).to be false
    end

    it 'denies access to supervisors' do
      expect(DepartmentPolicy.new(supervisor_user, department).update?).to be false
    end

    it 'denies access to operators' do
      expect(DepartmentPolicy.new(operator_user, department).update?).to be false
    end
  end

  describe '#destroy?' do
    it 'grants access to admins' do
      expect(DepartmentPolicy.new(admin_user, department).destroy?).to be true
    end

    it 'denies access to managers' do
      expect(DepartmentPolicy.new(manager_user, department).destroy?).to be false
    end

    it 'denies access to supervisors' do
      expect(DepartmentPolicy.new(supervisor_user, department).destroy?).to be false
    end

    it 'denies access to operators' do
      expect(DepartmentPolicy.new(operator_user, department).destroy?).to be false
    end
  end
end
