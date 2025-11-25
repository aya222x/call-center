class CallRecordingsController < ApplicationController
  before_action :set_call_recording, only: [:show]

  after_action :verify_authorized
  after_action :verify_policy_scoped, only: :index

  def index
    authorize CallRecording

    # Scope based on user role
    @recordings = policy_scope(CallRecording).includes(:user, :call_script, :evaluation)

    # Filter by status
    if params[:status].present? && params[:status] != 'all'
      @recordings = @recordings.by_status(params[:status])
    end

    # Filter by language
    if params[:language].present? && params[:language] != 'all'
      @recordings = @recordings.by_language(params[:language])
    end

    # Date range filter
    if params[:date_from].present? && params[:date_to].present?
      @recordings = @recordings.date_range(params[:date_from], params[:date_to])
    end

    # Search by customer name or phone
    if params[:search].present?
      @recordings = @recordings.where(
        'customer_name LIKE ? OR customer_phone LIKE ?',
        "%#{params[:search]}%",
        "%#{params[:search]}%"
      )
    end

    # Sort
    sort_column = params[:sort] || 'created_at'
    sort_direction = params[:direction] || 'desc'
    @recordings = @recordings.order("#{sort_column} #{sort_direction}")

    @pagy, @recordings = pagy(@recordings, items: 20)

    render inertia: 'CallRecordings/Index', props: {
      recordings: @recordings.map { |r| recording_props(r) },
      pagination: pagination_props(@pagy),
      filters: {
        search: params[:search].presence,
        status: params[:status].presence || 'all',
        language: params[:language].presence || 'all',
        date_from: params[:date_from].presence,
        date_to: params[:date_to].presence,
        sort: sort_column,
        direction: sort_direction
      },
      statuses: CallRecording.statuses.keys,
      languages: CallRecording.languages.keys,
      can_create: policy(CallRecording).create?,
      breadcrumbs: [
        { label: 'Call Recordings' }
      ]
    }
  end

  def show
    authorize @recording

    render inertia: 'CallRecordings/Show', props: {
      recording: recording_detail_props(@recording),
      evaluation: @recording.evaluation ? evaluation_props(@recording.evaluation) : nil,
      can_update: policy(@recording).update?,
      can_delete: policy(@recording).destroy?,
      breadcrumbs: [
        { label: 'Call Recordings', href: '/call-recordings' },
        { label: "Recording ##{@recording.id}" }
      ]
    }
  end

  def new
    authorize CallRecording

    render inertia: 'CallRecordings/New', props: {
      call_scripts: CallScript.active.map { |s| script_option(s) },
      breadcrumbs: [
        { label: 'Call Recordings', href: '/call-recordings' },
        { label: 'Upload New Recording' }
      ]
    }
  end

  def create
    authorize CallRecording

    @recording = CallRecording.new(recording_params)
    @recording.user = current_user
    @recording.status = :uploaded

    if @recording.save
      # TODO: Trigger background job for transcription
      redirect_to call_recording_path(@recording),
                  notice: 'Call recording uploaded successfully. Processing will begin shortly.'
    else
      redirect_to new_call_recording_path,
                  inertia: { errors: @recording.errors.to_hash }
    end
  end

  private

  def set_call_recording
    @recording = CallRecording.find(params[:id])
  end

  def recording_params
    params.require(:call_recording).permit(
      :call_script_id,
      :language,
      :call_date,
      :duration_seconds,
      :customer_name,
      :customer_phone,
      :audio_file
    )
  end

  def recording_props(recording)
    {
      id: recording.id,
      user: {
        id: recording.user.id,
        name: recording.user.name,
        email: recording.user.email
      },
      call_script: {
        id: recording.call_script.id,
        name: recording.call_script.name,
        call_type: recording.call_script.call_type
      },
      status: recording.status,
      language: recording.language,
      call_date: recording.call_date.iso8601,
      duration: recording.duration_formatted,
      customer_name: recording.customer_name,
      customer_phone: recording.customer_phone,
      overall_score: recording.evaluation&.overall_score,
      score_label: recording.evaluation&.score_label,
      score_color: recording.evaluation&.score_color,
      created_at: recording.created_at.iso8601
    }
  end

  def recording_detail_props(recording)
    recording_props(recording).merge(
      transcript: recording.transcript,
      error_message: recording.error_message,
      has_audio: recording.audio_file.attached?,
      audio_url: recording.audio_file.attached? ? url_for(recording.audio_file) : nil
    )
  end

  def evaluation_props(evaluation)
    {
      id: evaluation.id,
      overall_score: evaluation.overall_score,
      script_adherence_score: evaluation.script_adherence_score,
      politeness_score: evaluation.politeness_score,
      resolution_speed_score: evaluation.resolution_speed_score,
      terminology_score: evaluation.terminology_score,
      success_score: evaluation.success_score,
      recommendations: evaluation.recommendations,
      score_label: evaluation.score_label,
      score_color: evaluation.score_color
    }
  end

  def script_option(script)
    {
      id: script.id,
      name: script.name,
      call_type: script.call_type
    }
  end
end
