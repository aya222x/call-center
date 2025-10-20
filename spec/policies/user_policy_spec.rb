require 'rails_helper'

RSpec.describe UserPolicy, type: :policy do
  let(:super_admin) { create(:user, :super_admin) }
  let(:admin) { create(:user, :admin) }
  let(:regular_user) { create(:user) }
  let(:other_user) { create(:user) }

  describe "#index?" do
    it "grants access to super admins" do
      expect(UserPolicy.new(super_admin, User).index?).to be true
    end

    it "denies access to admins" do
      expect(UserPolicy.new(admin, User).index?).to be false
    end

    it "denies access to regular users" do
      expect(UserPolicy.new(regular_user, User).index?).to be false
    end
  end

  describe "#show?" do
    it "allows super admins to view any user" do
      expect(UserPolicy.new(super_admin, other_user).show?).to be true
    end

    it "allows users to view themselves" do
      expect(UserPolicy.new(regular_user, regular_user).show?).to be true
    end

    it "denies users viewing other users" do
      expect(UserPolicy.new(regular_user, other_user).show?).to be false
    end
  end

  describe "#create?" do
    it "grants access to super admins" do
      expect(UserPolicy.new(super_admin, User).create?).to be true
    end

    it "denies access to admins" do
      expect(UserPolicy.new(admin, User).create?).to be false
    end

    it "denies access to regular users" do
      expect(UserPolicy.new(regular_user, User).create?).to be false
    end
  end

  describe "#update?" do
    it "allows super admins to update any user" do
      expect(UserPolicy.new(super_admin, other_user).update?).to be true
    end

    it "allows users to update themselves" do
      expect(UserPolicy.new(regular_user, regular_user).update?).to be true
    end

    it "denies users updating other users" do
      expect(UserPolicy.new(regular_user, other_user).update?).to be false
    end
  end

  describe "#destroy?" do
    it "allows super admins to delete other users" do
      expect(UserPolicy.new(super_admin, other_user).destroy?).to be true
    end

    it "denies super admins deleting themselves" do
      expect(UserPolicy.new(super_admin, super_admin).destroy?).to be false
    end

    it "denies regular users deleting anyone" do
      expect(UserPolicy.new(regular_user, other_user).destroy?).to be false
    end

    it "denies users deleting themselves" do
      expect(UserPolicy.new(regular_user, regular_user).destroy?).to be false
    end
  end

  describe "Scope" do
    it "returns all users for super admins" do
      user1 = create(:user)
      user2 = create(:user)

      scope = Pundit.policy_scope!(super_admin, User)
      expect(scope).to include(user1, user2, super_admin)
    end

    it "returns only self for regular users" do
      user1 = create(:user)

      scope = Pundit.policy_scope!(regular_user, User)
      expect(scope).to eq([ regular_user ])
      expect(scope).not_to include(user1)
    end
  end

  describe "#permitted_attributes_for_create" do
    it "allows super admins to set role" do
      policy = UserPolicy.new(super_admin, User.new)
      expect(policy.permitted_attributes_for_create).to include(:role)
    end

    it "denies regular users from setting role" do
      policy = UserPolicy.new(regular_user, User.new)
      expect(policy.permitted_attributes_for_create).not_to include(:role)
    end
  end

  describe "#permitted_attributes_for_update" do
    it "allows super admins to update role" do
      policy = UserPolicy.new(super_admin, other_user)
      expect(policy.permitted_attributes_for_update).to include(:role)
    end

    it "denies regular users from updating role" do
      policy = UserPolicy.new(regular_user, regular_user)
      expect(policy.permitted_attributes_for_update).not_to include(:role)
    end
  end
end
