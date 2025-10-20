class Admin::AuditLogsController < Admin::BaseController
  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  # GET /admin/audit_logs
  def index
    authorize Audited::Audit
    audits = policy_scope(Audited::Audit).where(auditable_type: "User").includes(:user)

    # Search by user name or email
    if params[:search].present?
      search_term = "%#{params[:search]}%"
      user_ids = User.where("name LIKE ? OR email LIKE ?", search_term, search_term).pluck(:id)
      audits = audits.where("auditable_id IN (?) OR user_id IN (?)", user_ids, user_ids)
    end

    # Filter by action type
    if params[:action_filter].present?
      audits = audits.where(action: params[:action_filter])
    end

    # Sort
    sort_column = params[:sort_column].presence || "created_at"
    sort_direction = params[:sort_direction].presence || "desc"

    allowed_columns = %w[created_at action]
    sort_column = "created_at" unless allowed_columns.include?(sort_column)
    sort_direction = "desc" unless %w[asc desc].include?(sort_direction)

    audits = audits.order("#{sort_column} #{sort_direction}")

    @pagy, @audits = pagy(audits, items: 20)

    render inertia: "Admin/AuditLogs/Index", props: {
      audits: @audits.map { |a| audit_props(a) },
      pagination: pagination_props(@pagy),
      filters: {
        search: params[:search],
        action_filter: params[:action_filter],
        sort_column: sort_column,
        sort_direction: sort_direction
      }
    }
  end

  private

  def audit_props(audit)
    {
      id: audit.id,
      action: audit.action,
      auditable_type: audit.auditable_type,
      auditable_id: audit.auditable_id,
      user_id: audit.user_id,
      user_name: audit.user&.name || "System",
      user_email: audit.user&.email,
      audited_changes: audit.audited_changes,
      created_at: audit.created_at,
      remote_address: audit.remote_address
    }
  end
end
