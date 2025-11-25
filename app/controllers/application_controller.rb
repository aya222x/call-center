class ApplicationController < ActionController::Base
  include Authenticatable
  include Pagy::Backend
  include Pundit::Authorization

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Disable CSRF protection for JSON requests (JWT-based authentication)
  protect_from_forgery with: :null_session, if: -> { request.format.json? }

  # Inertia configuration
  inertia_share do
    {
      auth: {
        user: current_user ? {
          id: current_user.id,
          name: current_user.name,
          email: current_user.email,
          admin: current_user.admin?,
          avatar_url: current_user.avatar.attached? ? url_for(current_user.avatar) : nil
        } : nil
      },
      flash: {
        success: flash[:success],
        error: flash[:error],
        notice: flash[:notice]
      }
    }
  end

  private

  # Pundit uses this method to determine the current user
  def pundit_user
    current_user
  end

  def pagination_props(pagy)
    {
      page: pagy.page,
      pages: pagy.pages,
      count: pagy.count,
      from: pagy.from,
      to: pagy.to,
      prev: pagy.prev,
      next: pagy.next
    }
  end
end
