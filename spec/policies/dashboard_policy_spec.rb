require 'rails_helper'

RSpec.describe DashboardPolicy, type: :policy do
  let(:regular_user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }
  let(:super_admin_user) { create(:user, :super_admin) }

  describe "#index?" do
    it "denies access for regular users" do
      expect(DashboardPolicy.new(regular_user, :dashboard).index?).to be false
    end

    it "denies access for admin users" do
      expect(DashboardPolicy.new(admin_user, :dashboard).index?).to be false
    end

    it "grants access for super admin users" do
      expect(DashboardPolicy.new(super_admin_user, :dashboard).index?).to be true
    end
  end
end
