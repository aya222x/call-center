class HomeController < ApplicationController
  skip_before_action :set_current_user

  def index
    # Smart redirect: authenticated users go to dashboard, others see landing page
    if current_user
      redirect_to dashboard_path
    else
      render inertia: "Home/Landing"
    end
  end
end
