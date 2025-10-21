class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize User

    # Build search query with Ransack
    search_params = params[:q] || {}

    # Add search term if provided
    if params[:search].present?
      search_params = search_params.merge(
        name_or_email_cont: params[:search]
      )
    end

    # Add sorting - default to created_at desc
    sort_column = params[:sort] || "created_at"
    sort_direction = params[:direction] || "desc"
    search_params = search_params.merge(s: "#{sort_column} #{sort_direction}")

    @q = policy_scope(User).ransack(search_params)
    @users = @q.result

    @pagy, @users = pagy(@users, items: 20)

    render inertia: "Admin/Users/Index", props: {
      users: @users.map { |u| user_props(u) },
      pagination: pagination_props(@pagy),
      filters: {
        search: params[:search].presence,
        sort: sort_column,
        direction: sort_direction
      }
    }
  end

  def show
    authorize @user
    render inertia: "Admin/Users/Show", props: {
      user: user_props(@user)
    }
  end

  def new
    @user = User.new
    authorize @user
    render inertia: "Admin/Users/New"
  end

  def create
    authorize User

    outcome = Invitations::SendInvitation.run(
      current_user: current_user,
      email: params[:user][:email],
      name: params[:user][:name]
    )

    if outcome.valid?
      redirect_to admin_users_path, notice: "Invitation sent successfully to #{outcome.result.email}"
    else
      render inertia: "Admin/Users/New", props: {
        errors: outcome.errors.messages
      }
    end
  end

  def edit
    authorize @user
    render inertia: "Admin/Users/Edit", props: {
      user: user_props(@user)
    }
  end

  def update
    authorize @user

    # Only allow updating name and owner status, not password
    update_params = params.require(:user).permit(:name, :owner)

    if @user.update(update_params)
      redirect_to admin_users_path, notice: "User was successfully updated."
    else
      render inertia: "Admin/Users/Edit", props: {
        errors: @user.errors.messages,
        user: user_props(@user)
      }
    end
  end

  def resend_invitation
    @user = User.find(params[:id])
    authorize @user

    outcome = Invitations::ResendInvitation.run(
      current_user: current_user,
      user_id: @user.id
    )

    if outcome.valid?
      redirect_to admin_users_path, notice: "Invitation resent successfully to #{outcome.result.email}"
    else
      redirect_to admin_users_path, alert: outcome.errors.full_messages.join(", ")
    end
  end

  def destroy
    authorize @user

    begin
      @user.destroy!
      redirect_to admin_users_path, notice: "User was successfully deleted."
    rescue => e
      Rails.logger.error "Failed to delete user: #{e.message}"
      Rails.logger.error e.backtrace.join("\n")
      redirect_to admin_users_path, alert: "Failed to delete user: #{e.message}"
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    permitted_attrs = policy(@user || User).permitted_attributes
    params.require(:user).permit(*permitted_attrs)
  end

  def user_props(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      owner: user.owner,
      created_at: user.created_at.iso8601,
      invitation_pending: user.invitation_pending?,
      invitation_accepted: user.invitation_accepted?,
      active: user.active?
    }
  end
end
