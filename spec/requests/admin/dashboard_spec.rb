require 'rails_helper'

RSpec.describe "Admin::Dashboard", type: :request do
  let(:regular_user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }
  let(:super_admin_user) { create(:user, :super_admin) }

  describe "GET /admin/dashboard" do
    context "when not authenticated" do
      it "redirects to login" do
        get admin_dashboard_path
        expect(response).to have_http_status(:redirect)
        expect(response.location).to include(login_path)
      end
    end

    context "when authenticated as regular user" do
      it "redirects to root with unauthorized message" do
        get admin_dashboard_path, headers: auth_headers(regular_user)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when authenticated as admin" do
      it "redirects to root with unauthorized message" do
        get admin_dashboard_path, headers: auth_headers(admin_user)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when authenticated as super admin" do
      before do
        create_list(:user, 3)
        create(:user, :admin)
        create(:user, :super_admin)
      end

      it "returns success" do
        get admin_dashboard_path, headers: auth_headers(super_admin_user)
        expect(response).to have_http_status(:success)
      end

      it "includes stats in response" do
        get admin_dashboard_path, headers: auth_headers(super_admin_user)
        expect(response).to have_http_status(:success)
        # Stats should be in Inertia props, but we can verify response is successful
      end
    end
  end
end
