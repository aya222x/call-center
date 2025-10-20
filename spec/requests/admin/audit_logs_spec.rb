require 'rails_helper'

RSpec.describe "Admin::AuditLogs", type: :request do
  let(:regular_user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }
  let(:super_admin_user) { create(:user, :super_admin) }

  before do
    # Create some audit records
    test_user = create(:user)
    test_user.update(name: "Updated Name")
  end

  describe "GET /admin/audit_logs" do
    context "when not authenticated" do
      it "redirects to login" do
        get admin_audit_logs_path
        expect(response).to have_http_status(:redirect)
        expect(response.location).to include(login_path)
      end
    end

    context "when authenticated as regular user" do
      it "redirects to root with unauthorized message" do
        get admin_audit_logs_path, headers: auth_headers(regular_user)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when authenticated as admin" do
      it "redirects to root with unauthorized message" do
        get admin_audit_logs_path, headers: auth_headers(admin_user)
        expect(response).to redirect_to(root_path)
        expect(flash[:alert]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when authenticated as super admin" do
      it "returns success" do
        get admin_audit_logs_path, headers: auth_headers(super_admin_user)
        expect(response).to have_http_status(:success)
      end

      it "returns audit logs data" do
        get admin_audit_logs_path, headers: auth_headers(super_admin_user)
        expect(response).to have_http_status(:success)
      end

      it "filters by search term" do
        get admin_audit_logs_path, params: { search: "Updated" }, headers: auth_headers(super_admin_user)
        expect(response).to have_http_status(:success)
      end

      it "filters by action" do
        get admin_audit_logs_path, params: { action_filter: "update" }, headers: auth_headers(super_admin_user)
        expect(response).to have_http_status(:success)
      end

      it "supports sorting" do
        get admin_audit_logs_path, params: { sort_column: "created_at", sort_direction: "asc" }, headers: auth_headers(super_admin_user)
        expect(response).to have_http_status(:success)
      end
    end
  end
end
