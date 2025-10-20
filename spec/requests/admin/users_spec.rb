require 'rails_helper'

RSpec.describe "Admin::Users", type: :request do
  let(:regular_user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }
  let(:super_admin_user) { create(:user, :super_admin) }
  let(:other_user) { create(:user) }

  describe "GET /admin/users" do
    context "when not authenticated" do
      it "redirects to login" do
        get admin_users_path
        expect(response).to have_http_status(:redirect)
        expect(response.location).to include(login_path)
      end
    end

    context "when authenticated as regular user" do
      it "redirects to root with unauthorized message" do
        get admin_users_path, headers: auth_headers(regular_user)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when authenticated as admin" do
      it "redirects to root with unauthorized message" do
        get admin_users_path, headers: auth_headers(admin_user)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when authenticated as super admin" do
      it "returns success" do
        get admin_users_path, headers: auth_headers(super_admin_user)
        expect(response).to have_http_status(:success)
      end

      it "returns users data" do
        create_list(:user, 3)
        get admin_users_path, headers: auth_headers(super_admin_user)
        expect(response).to have_http_status(:success)
      end
    end
  end

  describe "GET /admin/users/:id" do
    context "when authenticated as super admin" do
      it "returns success for viewing any user" do
        get admin_user_path(other_user), headers: auth_headers(super_admin_user)
        expect(response).to have_http_status(:success)
      end
    end

    context "when authenticated as regular user" do
      it "redirects to root" do
        get admin_user_path(other_user), headers: auth_headers(regular_user)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "POST /admin/users" do
    let(:valid_attributes) do
      {
        user: {
          name: "New User",
          email: "newuser@example.com",
          password: "password123",
          password_confirmation: "password123",
          role: "user"
        }
      }
    end

    context "when authenticated as super admin" do
      it "creates a new user" do
        super_admin_user # Force creation before counting
        expect {
          post admin_users_path, params: valid_attributes, headers: auth_headers(super_admin_user)
        }.to change(User, :count).by(1)
      end

      it "redirects to users index" do
        post admin_users_path, params: valid_attributes, headers: auth_headers(super_admin_user)
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to eq("User was successfully created.")
      end
    end

    context "when authenticated as regular user" do
      it "does not create a user" do
        regular_user # Force creation before counting
        initial_count = User.count
        post admin_users_path, params: valid_attributes, headers: auth_headers(regular_user)
        expect(User.count).to eq(initial_count)
      end

      it "redirects to root" do
        post admin_users_path, params: valid_attributes, headers: auth_headers(regular_user)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "PATCH /admin/users/:id" do
    let(:update_attributes) do
      {
        user: {
          name: "Updated Name"
        }
      }
    end

    context "when authenticated as super admin" do
      it "updates the user" do
        patch admin_user_path(other_user), params: update_attributes, headers: auth_headers(super_admin_user)
        expect(other_user.reload.name).to eq("Updated Name")
      end

      it "redirects to users index" do
        patch admin_user_path(other_user), params: update_attributes, headers: auth_headers(super_admin_user)
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to eq("User was successfully updated.")
      end
    end

    context "when authenticated as regular user" do
      it "does not update the user" do
        original_name = other_user.name
        patch admin_user_path(other_user), params: update_attributes, headers: auth_headers(regular_user)
        expect(other_user.reload.name).to eq(original_name)
      end

      it "redirects to root" do
        patch admin_user_path(other_user), params: update_attributes, headers: auth_headers(regular_user)
        expect(response).to redirect_to(root_path)
      end
    end
  end

  describe "DELETE /admin/users/:id" do
    let!(:user_to_delete) { create(:user) }

    context "when authenticated as super admin" do
      it "deletes the user" do
        super_admin_user # Force creation
        user_to_delete # Force creation
        expect {
          delete admin_user_path(user_to_delete), headers: auth_headers(super_admin_user)
        }.to change(User, :count).by(-1)
      end

      it "cannot delete self" do
        super_admin_user # Force creation
        initial_count = User.count
        delete admin_user_path(super_admin_user), headers: auth_headers(super_admin_user)
        expect(User.count).to eq(initial_count)
      end

      it "redirects to users index" do
        delete admin_user_path(user_to_delete), headers: auth_headers(super_admin_user)
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to eq("User was successfully deleted.")
      end
    end

    context "when authenticated as regular user" do
      it "does not delete the user" do
        regular_user # Force creation
        user_to_delete # Force creation
        initial_count = User.count
        delete admin_user_path(user_to_delete), headers: auth_headers(regular_user)
        expect(User.count).to eq(initial_count)
      end

      it "redirects to root" do
        delete admin_user_path(user_to_delete), headers: auth_headers(regular_user)
        expect(response).to redirect_to(root_path)
      end
    end
  end
end
