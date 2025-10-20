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

    # Filter by role
    if params[:role].present?
      if params[:role] == "super_admin"
        @users = @users.where(super_admin: true)
      else
        @users = @users.where(role: params[:role], super_admin: false)
      end
    end

    @pagy, @users = pagy(@users, items: 20)

    render inertia: "Admin/Users/Index", props: {
      users: @users.map { |u| user_props(u) },
      pagination: pagination_props(@pagy),
      filters: {
        search: params[:search].presence,
        role: params[:role].presence,
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
    @user = User.new(user_params)
    authorize @user

    if @user.save
      redirect_to admin_users_path, notice: "User was successfully created."
    else
      render inertia: "Admin/Users/New", props: {
        errors: @user.errors.messages,
        user: @user.attributes
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
    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User was successfully updated."
    else
      render inertia: "Admin/Users/Edit", props: {
        errors: @user.errors.messages,
        user: user_props(@user)
      }
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
      role: user.role,
      super_admin: user.super_admin,
      created_at: user.created_at.iso8601
    }
  end
end
