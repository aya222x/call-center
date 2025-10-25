require 'rails_helper'

RSpec.describe "Admin::Console", type: :request, inertia: true do
  let(:regular_user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }

  describe "GET /admin/console" do
    context "when not authenticated" do
      it "redirects to login with return_to" do
        get admin_console_path
        expect(response).to have_http_status(:redirect)
        expect(response.location).to include(login_path)
        expect(response.location).to include('return_to')
      end

      it "returns 401 for Inertia XHR requests" do
        get admin_console_path, headers: { 'X-Inertia' => 'true', 'X-Inertia-Version' => InertiaRails.configuration.version }
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Unauthorized")
      end
    end

    context "when authenticated as regular user" do
      it "redirects to root" do
        get admin_console_path, headers: auth_headers(regular_user)
        expect(response).to redirect_to(root_path)
      end

      it "returns 403 for Inertia XHR requests" do
        get admin_console_path, headers: auth_headers(regular_user, inertia: true)
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when authenticated as super admin" do
      before do
        create_list(:user, 3)
        create(:user, :admin)
      end

      it "returns success" do
        get admin_console_path, headers: auth_headers(admin_user)
        expect(response).to have_http_status(:success)
      end

      it "renders Admin/Console component" do
        get admin_console_path, headers: auth_headers(admin_user, inertia: true)
        expect(inertia).to render_component("Admin/Console")
      end

      it "includes stats in props" do
        get admin_console_path, headers: auth_headers(admin_user, inertia: true)

        expect(inertia).to include_props("stats" => {
          "total_users" => 5,  # 3 regular + 1 admin from before block + 1 admin_user
          "admins" => 2,
          "regular_users" => 3,
          "active_sessions" => 0
        })
      end

      it "provides access to individual props" do
        get admin_console_path, headers: auth_headers(admin_user, inertia: true)

        expect(inertia.props["stats"]["total_users"]).to eq(5)
        expect(inertia.props["stats"]["admins"]).to eq(2)
      end
    end
  end
end
