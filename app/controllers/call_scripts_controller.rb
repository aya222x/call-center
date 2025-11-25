class CallScriptsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_call_script, only: [:show, :edit, :update]

  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize CallScript

    @scripts = policy_scope(CallScript).includes(:department)

    # Filter by department
    if params[:department_id].present?
      @scripts = @scripts.where(department_id: params[:department_id])
    end

    # Filter by call type
    if params[:call_type].present? && params[:call_type] != 'all'
      @scripts = @scripts.where(call_type: params[:call_type])
    end

    # Filter by active status
    if params[:active].present?
      @scripts = @scripts.where(active: params[:active] == 'true')
    end

    @scripts = @scripts.order(created_at: :desc)

    render inertia: 'CallScripts/Index', props: {
      scripts: @scripts.map { |s| script_props(s) },
      departments: Department.active.map { |d| { id: d.id, name: d.name } },
      call_types: CallScript.call_types.keys,
      filters: {
        department_id: params[:department_id].presence,
        call_type: params[:call_type].presence || 'all',
        active: params[:active].presence
      },
      can_create: policy(CallScript).create?,
      breadcrumbs: [
        { label: 'Call Scripts' }
      ]
    }
  end

  def show
    authorize @script

    render inertia: 'CallScripts/Show', props: {
      script: script_detail_props(@script),
      can_update: policy(@script).update?,
      can_delete: policy(@script).destroy?,
      breadcrumbs: [
        { label: 'Call Scripts', href: '/call_scripts' },
        { label: @script.name }
      ]
    }
  end

  def new
    authorize CallScript

    render inertia: 'CallScripts/New', props: {
      departments: Department.active.map { |d| { id: d.id, name: d.name } },
      call_types: CallScript.call_types.keys,
      breadcrumbs: [
        { label: 'Call Scripts', href: '/call_scripts' },
        { label: 'Create New Script' }
      ]
    }
  end

  def create
    authorize CallScript

    @script = CallScript.new(script_params)

    if @script.save
      redirect_to call_script_path(@script),
                  notice: 'Call script created successfully.'
    else
      redirect_to new_call_script_path,
                  inertia: { errors: @script.errors.to_hash }
    end
  end

  def edit
    authorize @script

    render inertia: 'CallScripts/Edit', props: {
      script: script_detail_props(@script),
      departments: Department.active.map { |d| { id: d.id, name: d.name } },
      call_types: CallScript.call_types.keys,
      breadcrumbs: [
        { label: 'Call Scripts', href: '/call_scripts' },
        { label: @script.name, href: call_script_path(@script) },
        { label: 'Edit' }
      ]
    }
  end

  def update
    authorize @script

    if @script.update(script_params)
      redirect_to call_script_path(@script),
                  notice: 'Call script updated successfully.'
    else
      redirect_to edit_call_script_path(@script),
                  inertia: { errors: @script.errors.to_hash }
    end
  end

  private

  def set_call_script
    @script = CallScript.find(params[:id])
  end

  def script_params
    params.require(:call_script).permit(
      :name,
      :call_type,
      :content,
      :department_id,
      :active
    )
  end

  def script_props(script)
    {
      id: script.id,
      name: script.name,
      call_type: script.call_type,
      department: {
        id: script.department.id,
        name: script.department.name
      },
      active: script.active,
      created_at: script.created_at.iso8601
    }
  end

  def script_detail_props(script)
    script_props(script).merge(
      content: script.content,
      recordings_count: script.call_recordings.count
    )
  end
end
