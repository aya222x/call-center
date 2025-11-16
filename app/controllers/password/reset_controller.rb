class Password::ResetController < ApplicationController
  skip_before_action :set_current_user, only: [ :new, :show ]

  # GET /password/forgot
  def new
    render inertia: "Auth/ForgotPassword"
  end

  # POST /password/forgot
  def forgot
    outcome = Auth::RequestPasswordReset.run(email: params[:email])

    if outcome.valid?
      # In production, would send email here
      render json: { message: "If that email exists, password reset instructions have been sent" }
    else
      render json: { error: outcome.errors.full_messages.join(", ") }, status: :unprocessable_content
    end
  end

  # GET /password/reset?token=xyz
  def show
    render inertia: "Auth/ResetPassword", props: { token: params[:token] }
  end

  # PUT /password/reset
  def update
    outcome = Auth::ResetPassword.run(
      token: params[:token],
      password: params[:password],
      password_confirmation: params[:password_confirmation]
    )

    if outcome.valid?
      render json: { message: "Password has been reset successfully" }
    else
      render json: { error: outcome.errors.full_messages.join(", ") }, status: :unprocessable_content
    end
  end
end
