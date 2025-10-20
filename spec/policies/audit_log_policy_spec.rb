require 'rails_helper'

RSpec.describe Audited::AuditPolicy, type: :policy do
  let(:regular_user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }
  let(:super_admin_user) { create(:user, :super_admin) }
  let(:audit) { Audited::Audit.create!(auditable_type: 'User', action: 'create', audited_changes: {}) }

  describe "#index?" do
    it "denies access for regular users" do
      expect(Audited::AuditPolicy.new(regular_user, audit).index?).to be false
    end

    it "denies access for admin users" do
      expect(Audited::AuditPolicy.new(admin_user, audit).index?).to be false
    end

    it "grants access for super admin users" do
      expect(Audited::AuditPolicy.new(super_admin_user, audit).index?).to be true
    end
  end

  describe "Scope" do
    let!(:user1) { create(:user) }
    let!(:user2) { create(:user) }

    before do
      # Create some audit records
      user1.update(name: "Updated Name 1")
      user2.update(name: "Updated Name 2")
    end

    it "returns all audits for super admin" do
      scope = Pundit.policy_scope!(super_admin_user, Audited::Audit)
      expect(scope.count).to be > 0
    end

    it "returns no audits for regular user" do
      scope = Pundit.policy_scope!(regular_user, Audited::Audit)
      expect(scope.count).to eq(0)
    end

    it "returns no audits for admin user" do
      scope = Pundit.policy_scope!(admin_user, Audited::Audit)
      expect(scope.count).to eq(0)
    end
  end
end
