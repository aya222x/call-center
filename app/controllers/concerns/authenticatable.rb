module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :set_current_user
  end

  private

  def set_current_user
    @current_user = nil
    token = request.headers["Authorization"]&.split(" ")&.last

    return unless token

    decoded = Auth::JwtService.decode(token)
    return unless decoded

    user = User.find_by(id: decoded["user_id"])
    return unless user

    # Validate password_version matches (invalidates JWT if password changed)
    if decoded["password_version"] && user.password_version != decoded["password_version"]
      return
    end

    @current_user = user
  end

  def current_user
    @current_user
  end

  def authenticate_user!
    unless current_user
      render_unauthorized
    end
  end

  def current_user?(user)
    current_user == user
  end

  def render_unauthorized(message = "Unauthorized")
    # Distinguish between initial page loads and Inertia XHR requests
    if request.headers["X-Inertia"]
      # Inertia XHR request: Return 401 JSON (frontend handles redirect)
      render json: { error: message }, status: :unauthorized
    else
      # Initial page load: Redirect to login (JWT not in request yet, it's in localStorage)
      return_to = request.fullpath unless request.fullpath == login_path
      redirect_to login_path(return_to: return_to)
    end
  end
end
