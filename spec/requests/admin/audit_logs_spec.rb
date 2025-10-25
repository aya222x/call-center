require 'rails_helper'

RSpec.describe "Admin::AuditLogs", type: :request, inertia: true do
  let(:regular_user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }

  before do
    # Create some audit records
    test_user = create(:user)
    test_user.update(name: "Updated Name")
  end

  describe "GET /admin/audit_logs" do
    context "when not authenticated" do
      it "redirects to login with return_to" do
        get admin_audit_logs_path
        expect(response).to have_http_status(:redirect)
        expect(response.location).to include(login_path)
        expect(response.location).to include('return_to')
      end

      it "returns 401 for Inertia XHR requests" do
        get admin_audit_logs_path, headers: { 'X-Inertia' => 'true', 'X-Inertia-Version' => InertiaRails.configuration.version }
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Unauthorized")
      end
    end

    context "when authenticated as regular user" do
      it "redirects to root" do
        get admin_audit_logs_path, headers: auth_headers(regular_user)
        expect(response).to redirect_to(root_path)
      end

      it "returns 403 for Inertia XHR requests" do
        get admin_audit_logs_path, headers: auth_headers(regular_user, inertia: true)
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when authenticated as super admin" do
      it "returns success" do
        get admin_audit_logs_path, headers: auth_headers(admin_user)
        expect(response).to have_http_status(:success)
      end

      context "with Inertia requests" do
        it "renders Admin/AuditLogs/Index component" do
          get admin_audit_logs_path, headers: auth_headers(admin_user, inertia: true)
          expect(inertia).to render_component("Admin/AuditLogs/Index")
        end

        it "includes audit logs in props" do
          get admin_audit_logs_path, headers: auth_headers(admin_user, inertia: true)

          expect(inertia.props["audits"]).to be_an(Array)
          expect(inertia.props["audits"]).not_to be_empty
        end

        it "includes filters in props" do
          get admin_audit_logs_path, params: { search: "Updated" }, headers: auth_headers(admin_user, inertia: true)

          expect(inertia.props["filters"]["search"]).to eq("Updated")
        end
      end
    end
  end
end
