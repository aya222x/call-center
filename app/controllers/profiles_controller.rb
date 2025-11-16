class ProfilesController < ApplicationController
  before_action :authenticate_user!

  # GET /profile
  def show
    render inertia: "Profile/Show", props: {
      user: user_props(current_user)
    }
  end

  # GET /profile/edit
  def edit
    render inertia: "Profile/Edit", props: {
      user: user_props(current_user)
    }
  end

  # PATCH /profile
  def update
    if current_user.update(profile_params)
      render json: { message: "Profile updated successfully", user: user_props(current_user) }
    else
      render json: { errors: current_user.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def profile_params
    params.require(:user).permit(:name, :email, :password, :password_confirmation, :avatar)
  end

  def user_props(user)
    avatar_url = user.avatar.attached? ? url_for(user.avatar) : nil

    {
      id: user.id,
      name: user.name,
      email: user.email,
      admin: user.admin?,
      created_at: user.created_at,
      avatar_url: avatar_url
    }
  end
end
