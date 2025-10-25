require 'rails_helper'

RSpec.describe "Admin::Users", type: :request, inertia: true do
  let(:regular_user) { create(:user) }
  let(:admin_user) { create(:user, :admin) }
  let(:other_user) { create(:user) }

  describe "GET /admin/users" do
    context "when not authenticated" do
      it "redirects to login with return_to" do
        get admin_users_path
        expect(response).to have_http_status(:redirect)
        expect(response.location).to include(login_path)
        expect(response.location).to include('return_to')
      end

      it "returns 401 for Inertia XHR requests" do
        get admin_users_path, headers: { 'X-Inertia' => 'true', 'X-Inertia-Version' => InertiaRails.configuration.version }
        expect(response).to have_http_status(:unauthorized)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("Unauthorized")
      end
    end

    context "when authenticated as regular user" do
      it "redirects to root" do
        get admin_users_path, headers: auth_headers(regular_user)
        expect(response).to redirect_to(root_path)
      end

      it "returns 403 for Inertia XHR requests" do
        get admin_users_path, headers: auth_headers(regular_user, inertia: true)
        expect(response).to have_http_status(:forbidden)
        json = JSON.parse(response.body)
        expect(json["error"]).to eq("You are not authorized to perform this action.")
      end
    end

    context "when authenticated as super admin" do
      it "returns success" do
        get admin_users_path, headers: auth_headers(admin_user)
        expect(response).to have_http_status(:success)
      end

      context "with Inertia requests" do
        it "renders Admin/Users/Index component" do
          get admin_users_path, headers: auth_headers(admin_user, inertia: true)
          expect(inertia).to render_component("Admin/Users/Index")
        end

        it "includes users in props" do
          user1 = create(:user, name: "Alice", email: "alice@example.com")
          user2 = create(:user, name: "Bob", email: "bob@example.com")

          get admin_users_path, headers: auth_headers(admin_user, inertia: true)

          expect(inertia.props["users"]).to be_an(Array)
          expect(inertia.props["users"].map { |u| u["id"] }).to include(user1.id, user2.id, admin_user.id)
        end

        it "includes pagination props" do
          create_list(:user, 25)  # More than page size (20)

          get admin_users_path, headers: auth_headers(admin_user, inertia: true)

          expect(inertia.props["pagination"]).to be_present
          expect(inertia.props["pagination"]["page"]).to eq(1)
          expect(inertia.props["pagination"]["pages"]).to be > 1
        end

        it "filters users by search term" do
          alice = create(:user, name: "Alice Smith", email: "alice@example.com")
          bob = create(:user, name: "Bob Jones", email: "bob@example.com")

          get admin_users_path, params: { search: "Alice" }, headers: auth_headers(admin_user, inertia: true)

          user_ids = inertia.props["users"].map { |u| u["id"] }
          expect(user_ids).to include(alice.id)
          expect(user_ids).not_to include(bob.id)
        end

        it "includes search filter in props" do
          get admin_users_path, params: { search: "test" }, headers: auth_headers(admin_user, inertia: true)

          expect(inertia.props["filters"]["search"]).to eq("test")
        end

        it "includes sort and direction in filters" do
          get admin_users_path, params: { sort: "email", direction: "asc" }, headers: auth_headers(admin_user, inertia: true)

          expect(inertia.props["filters"]["sort"]).to eq("email")
          expect(inertia.props["filters"]["direction"]).to eq("asc")
        end

        it "uses default sort (created_at desc) when not specified" do
          get admin_users_path, headers: auth_headers(admin_user, inertia: true)

          expect(inertia.props["filters"]["sort"]).to eq("created_at")
          expect(inertia.props["filters"]["direction"]).to eq("desc")
        end

        it "filters users by status: active" do
          active_user = create(:user, email: "active@example.com", password: "password123")
          pending_user = create(:user, email: "pending@example.com", password_digest: nil, invitation_sent_at: Time.current)

          get admin_users_path, params: { status_filter: "active" }, headers: auth_headers(admin_user, inertia: true)

          user_ids = inertia.props["users"].map { |u| u["id"] }
          expect(user_ids).to include(active_user.id, admin_user.id)
          expect(user_ids).not_to include(pending_user.id)
        end

        it "filters users by status: pending" do
          active_user = create(:user, email: "active@example.com", password: "password123")
          pending_user = create(:user, email: "pending@example.com", password_digest: nil, invitation_sent_at: Time.current)

          get admin_users_path, params: { status_filter: "pending" }, headers: auth_headers(admin_user, inertia: true)

          user_ids = inertia.props["users"].map { |u| u["id"] }
          expect(user_ids).to include(pending_user.id)
          expect(user_ids).not_to include(active_user.id, admin_user.id)
        end

        it "filters users by status: inactive" do
          active_user = create(:user, email: "active@example.com", password: "password123")
          pending_user = create(:user, email: "pending@example.com", password_digest: nil, invitation_sent_at: Time.current)
          inactive_user = create(:user, email: "inactive@example.com", password_digest: nil, invitation_sent_at: nil)

          get admin_users_path, params: { status_filter: "inactive" }, headers: auth_headers(admin_user, inertia: true)

          user_ids = inertia.props["users"].map { |u| u["id"] }
          expect(user_ids).to include(inactive_user.id)
          expect(user_ids).not_to include(active_user.id, pending_user.id, admin_user.id)
        end

        it "includes status_filter in props" do
          get admin_users_path, params: { status_filter: "active" }, headers: auth_headers(admin_user, inertia: true)

          expect(inertia.props["filters"]["status_filter"]).to eq("active")
        end

        it "returns all users when status_filter is 'all' or not provided" do
          active_user = create(:user, email: "active@example.com", password: "password123")
          pending_user = create(:user, email: "pending@example.com", password_digest: nil, invitation_sent_at: Time.current)

          get admin_users_path, params: { status_filter: "all" }, headers: auth_headers(admin_user, inertia: true)

          user_ids = inertia.props["users"].map { |u| u["id"] }
          expect(user_ids).to include(active_user.id, pending_user.id, admin_user.id)
        end

        it "filters users by created_from date" do
          old_user = create(:user, email: "old@example.com", created_at: 10.days.ago)
          new_user = create(:user, email: "new@example.com", created_at: 2.days.ago)

          get admin_users_path, params: { created_from: 5.days.ago.to_date.to_s }, headers: auth_headers(admin_user, inertia: true)

          user_ids = inertia.props["users"].map { |u| u["id"] }
          expect(user_ids).to include(new_user.id, admin_user.id)
          expect(user_ids).not_to include(old_user.id)
        end

        it "filters users by created_to date" do
          old_user = create(:user, email: "old@example.com", created_at: 10.days.ago)
          new_user = create(:user, email: "new@example.com", created_at: 2.days.ago)

          get admin_users_path, params: { created_to: 5.days.ago.to_date.to_s }, headers: auth_headers(admin_user, inertia: true)

          user_ids = inertia.props["users"].map { |u| u["id"] }
          expect(user_ids).to include(old_user.id)
          expect(user_ids).not_to include(new_user.id)
        end

        it "filters users by date range (created_from and created_to)" do
          very_old_user = create(:user, email: "veryold@example.com", created_at: 20.days.ago)
          old_user = create(:user, email: "old@example.com", created_at: 10.days.ago)
          new_user = create(:user, email: "new@example.com", created_at: 2.days.ago)

          get admin_users_path, params: { created_from: 15.days.ago.to_date.to_s, created_to: 5.days.ago.to_date.to_s }, headers: auth_headers(admin_user, inertia: true)

          user_ids = inertia.props["users"].map { |u| u["id"] }
          expect(user_ids).to include(old_user.id)
          expect(user_ids).not_to include(very_old_user.id, new_user.id)
        end

        it "includes date filter params in props" do
          get admin_users_path, params: { created_from: "2025-01-01", created_to: "2025-01-31" }, headers: auth_headers(admin_user, inertia: true)

          expect(inertia.props["filters"]["created_from"]).to eq("2025-01-01")
          expect(inertia.props["filters"]["created_to"]).to eq("2025-01-31")
        end
      end
    end
  end

  describe "GET /admin/users/:id" do
    context "when authenticated as super admin" do
      it "returns success for viewing any user" do
        get admin_user_path(other_user), headers: auth_headers(admin_user)
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
          password_confirmation: "password123"
        }
      }
    end

    context "when authenticated as super admin" do
      it "creates a new user" do
        admin_user # Force creation before counting
        expect {
          post admin_users_path, params: valid_attributes, headers: auth_headers(admin_user)
        }.to change(User, :count).by(1)
      end

      it "redirects to users index" do
        post admin_users_path, params: valid_attributes, headers: auth_headers(admin_user)
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to match(/Invitation sent successfully to/)
      end

      # Inertia-specific tests for error handling
      context "with Inertia request and validation errors" do
        let(:invalid_attributes) do
          {
            user: {
              name: "x",  # Invalid - too short (minimum 2)
              email: ""   # Invalid - blank
            }
          }
        end

        it "re-renders New component with errors in props" do
          post admin_users_path, params: invalid_attributes, headers: auth_headers(admin_user, inertia: true)

          expect(inertia).to render_component("Admin/Users/New")
        end

        it "includes validation errors in props" do
          post admin_users_path, params: invalid_attributes, headers: auth_headers(admin_user, inertia: true)

          expect(inertia.props["errors"]).to be_present
          expect(inertia.props["errors"]).to be_a(Hash)
        end

        it "does not create user when validation fails" do
          admin_user  # Force creation
          initial_count = User.count

          post admin_users_path, params: invalid_attributes, headers: auth_headers(admin_user, inertia: true)

          expect(User.count).to eq(initial_count)
        end
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
        patch admin_user_path(other_user), params: update_attributes, headers: auth_headers(admin_user)
        expect(other_user.reload.name).to eq("Updated Name")
      end

      it "redirects to users index with flash message" do
        patch admin_user_path(other_user), params: update_attributes, headers: auth_headers(admin_user)
        expect(response).to redirect_to(admin_users_path)
        expect(flash[:notice]).to eq("User was successfully updated.")
      end

      # Inertia-specific test for flash messages
      context "with Inertia request" do
        it "redirects with flash message in session" do
          patch admin_user_path(other_user), params: update_attributes, headers: auth_headers(admin_user, inertia: true)

          expect(response).to have_http_status(:see_other)  # 303 redirect for Inertia
          follow_redirect!

          # Flash should be available on next request
          get admin_users_path, headers: auth_headers(admin_user, inertia: true)
          expect(inertia.props["flash"]["notice"]).to eq("User was successfully updated.")
        end
      end

      # Inertia-specific test for validation errors
      context "with Inertia request and validation errors" do
        let(:invalid_update) do
          {
            user: {
              name: ""  # Invalid - too short
            }
          }
        end

        it "re-renders Edit component with errors" do
          patch admin_user_path(other_user), params: invalid_update, headers: auth_headers(admin_user, inertia: true)

          expect(inertia).to render_component("Admin/Users/Edit")
          expect(inertia.props["errors"]).to be_present
        end
      end
    end

    context "when authenticated as regular user" do
      it "redirects to root" do
        patch admin_user_path(other_user), params: update_attributes, headers: auth_headers(regular_user)
        expect(response).to redirect_to(root_path)
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
        admin_user # Force creation
        user_to_delete # Force creation
        expect {
          delete admin_user_path(user_to_delete), headers: auth_headers(admin_user)
        }.to change(User, :count).by(-1)
      end

      it "cannot delete self" do
        admin_user # Force creation
        initial_count = User.count
        delete admin_user_path(admin_user), headers: auth_headers(admin_user)
        expect(User.count).to eq(initial_count)
      end

      it "redirects to users index" do
        delete admin_user_path(user_to_delete), headers: auth_headers(admin_user)
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
