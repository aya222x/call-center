require "rails_helper"

RSpec.describe "Invitations", type: :request, inertia: true do
  let(:invited_user) { create(:user, :invited) }
  let(:token) { invited_user.invitation_token }

  describe "GET /invitations/:token" do
    context "with valid token" do
      it "renders the accept invitation page" do
        get accept_invitation_path(token: token)

        expect(response).to have_http_status(:ok)
      end

      context "with Inertia request" do
        it "renders Invitations/Accept component" do
          get accept_invitation_path(token: token), headers: { 'X-Inertia' => 'true', 'X-Inertia-Version' => '1.0' }

          expect(inertia).to render_component("Invitations/Accept")
        end

        it "includes token in props" do
          get accept_invitation_path(token: token), headers: { 'X-Inertia' => 'true', 'X-Inertia-Version' => '1.0' }

          expect(inertia.props["token"]).to eq(token)
        end

        it "includes user data in props" do
          get accept_invitation_path(token: token), headers: { 'X-Inertia' => 'true', 'X-Inertia-Version' => '1.0' }

          expect(inertia).to include_props("user" => {
            "name" => invited_user.name,
            "email" => invited_user.email
          })
        end
      end
    end

    context "with invalid token" do
      it "redirects to login with error message" do
        get accept_invitation_path(token: "invalid-token")

        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(response.body).to include("Invalid or expired invitation")
      end
    end

    context "with already accepted invitation" do
      let(:accepted_user) { create(:user, :invitation_accepted) }

      before do
        accepted_user.update_columns(invitation_token: "some-token")
      end

      it "redirects to login with error message" do
        get accept_invitation_path(token: "some-token")

        expect(response).to redirect_to(login_path)
        follow_redirect!
        expect(response.body).to include("Invalid or expired invitation")
      end
    end
  end

  describe "POST /invitations/:token/accept" do
    let(:valid_params) do
      {
        password: "password123",
        password_confirmation: "password123"
      }
    end

    context "with valid parameters" do
      it "returns success status" do
        post "/invitations/#{token}/accept", params: valid_params, as: :json

        expect(response).to have_http_status(:ok)
      end

      it "returns user data" do
        post "/invitations/#{token}/accept", params: valid_params, as: :json

        json = JSON.parse(response.body)
        expect(json["user"]["id"]).to eq(invited_user.id)
        expect(json["user"]["name"]).to eq(invited_user.name)
        expect(json["user"]["email"]).to eq(invited_user.email)
        expect(json["user"]["admin"]).to eq(invited_user.admin)
      end

      it "returns JWT token" do
        post "/invitations/#{token}/accept", params: valid_params, as: :json

        json = JSON.parse(response.body)
        expect(json["jwt_token"]).to be_present
      end

      it "returns refresh token" do
        post "/invitations/#{token}/accept", params: valid_params, as: :json

        json = JSON.parse(response.body)
        expect(json["refresh_token"]).to be_present
      end

      it "accepts the invitation" do
        post "/invitations/#{token}/accept", params: valid_params, as: :json

        invited_user.reload
        expect(invited_user.invitation_accepted_at).to be_present
        expect(invited_user.invitation_token).to be_nil
        expect(invited_user.active?).to be true
      end

      it "sets the password" do
        post "/invitations/#{token}/accept", params: valid_params, as: :json

        invited_user.reload
        expect(invited_user.authenticate("password123")).to eq(invited_user)
      end
    end

    context "with invalid parameters" do
      it "returns error when password is blank" do
        post "/invitations/#{token}/accept", params: { password: "", password_confirmation: "" }, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end

      it "returns error when password is too short" do
        post "/invitations/#{token}/accept", params: { password: "short", password_confirmation: "short" }, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end

      it "returns error when passwords don't match" do
        post "/invitations/#{token}/accept", params: { password: "password123", password_confirmation: "different123" }, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["errors"]).to include("Password confirmation doesn't match password")
      end

      it "returns error with invalid token" do
        post "/invitations/invalid-token/accept", params: valid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end

    context "with already accepted invitation" do
      let(:accepted_user) { create(:user, :invitation_accepted) }

      before do
        accepted_user.update_columns(invitation_token: "some-token")
      end

      it "returns error" do
        post "/invitations/some-token/accept", params: valid_params, as: :json

        expect(response).to have_http_status(:unprocessable_content)
        json = JSON.parse(response.body)
        expect(json["errors"]).to be_present
      end
    end
  end
end
