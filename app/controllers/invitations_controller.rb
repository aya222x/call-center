class InvitationsController < ApplicationController
  # Public controller - no authentication required

  # GET /invitations/:token
  def show
    @user = User.find_by(invitation_token: params[:token])

    if @user.nil? || !@user.invitation_pending?
      redirect_to login_path, flash: { error: "Invalid or expired invitation" }
      return
    end

    render inertia: "Invitations/Accept", props: {
      token: params[:token],
      user: {
        name: @user.name,
        email: @user.email
      }
    }
  end

  # POST /invitations/:token/accept
  def accept
    outcome = Invitations::AcceptInvitation.run(
      invitation_token: params[:token],
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )

    if outcome.valid?
      user = outcome.result

      # Log the user in
      jwt_token = Services::Auth::JwtService.encode(user_id: user.id)
      refresh_token_data = Services::Auth::JwtService.generate_refresh_token(user)

      render json: {
        user: {
          id: user.id,
          name: user.name,
          email: user.email,
          owner: user.owner?,
          avatar_url: user.avatar.attached? ? url_for(user.avatar) : nil
        },
        jwt_token: jwt_token,
        refresh_token: refresh_token_data[:token]
      }, status: :ok
    else
      render json: { errors: outcome.errors.full_messages }, status: :unprocessable_entity
    end
  end
end
