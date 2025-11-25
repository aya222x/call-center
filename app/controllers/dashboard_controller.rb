class DashboardController < ApplicationController
  before_action :authenticate_user!

  after_action :verify_authorized

  def index
    authorize :dashboard, :index?

    # Total recordings count
    recordings_scope = policy_scope(CallRecording)
    total_recordings = recordings_scope.count

    # Recordings by status
    status_breakdown = recordings_scope.group(:status).count

    # Recent recordings (last 10)
    recent_recordings = recordings_scope
                          .includes(:user, :call_script, :evaluation)
                          .order(created_at: :desc)
                          .limit(10)

    # Average scores
    completed_evaluations = Evaluation.joins(:call_recording)
                                      .merge(recordings_scope)

    avg_overall_score = completed_evaluations.average(:overall_score)&.to_f&.round(2) || 0
    avg_adherence = completed_evaluations.average(:script_adherence_score)&.to_f&.round(2) || 0
    avg_politeness = completed_evaluations.average(:politeness_score)&.to_f&.round(2) || 0
    avg_speed = completed_evaluations.average(:resolution_speed_score)&.to_f&.round(2) || 0
    avg_terminology = completed_evaluations.average(:terminology_score)&.to_f&.round(2) || 0
    avg_success = completed_evaluations.average(:success_score)&.to_f&.round(2) || 0

    # Top performers (operators with highest average scores)
    top_performers = if current_user.admin? || current_user.manager?
                       User.operator
                           .joins(call_recordings: :evaluation)
                           .select('users.*, AVG(evaluations.overall_score) as avg_score')
                           .group('users.id')
                           .order('avg_score DESC')
                           .limit(5)
                           .map { |u| operator_stat(u) }
                     else
                       []
                     end

    # Recent activity by language
    language_breakdown = recordings_scope.group(:language).count

    render inertia: 'Dashboard', props: {
      stats: {
        total_recordings: total_recordings,
        completed_count: status_breakdown['completed'] || 0,
        pending_count: (status_breakdown['uploaded'] || 0) +
                       (status_breakdown['transcribing'] || 0) +
                       (status_breakdown['analyzing'] || 0),
        failed_count: status_breakdown['failed'] || 0,
        avg_overall_score: avg_overall_score,
        avg_adherence: avg_adherence,
        avg_politeness: avg_politeness,
        avg_speed: avg_speed,
        avg_terminology: avg_terminology,
        avg_success: avg_success
      },
      language_breakdown: language_breakdown.transform_keys(&:to_s),
      recent_recordings: recent_recordings.map { |r| recording_summary(r) },
      top_performers: top_performers,
      can_view_operators: current_user.admin? || current_user.manager?,
      breadcrumbs: [
        { label: 'Dashboard' }
      ]
    }
  end

  private

  def recording_summary(recording)
    {
      id: recording.id,
      user_name: recording.user.name,
      call_script_name: recording.call_script.name,
      status: recording.status,
      language: recording.language,
      call_date: recording.call_date.iso8601,
      overall_score: recording.evaluation&.overall_score,
      score_color: recording.evaluation&.score_color,
      created_at: recording.created_at.iso8601
    }
  end

  def operator_stat(user)
    {
      id: user.id,
      name: user.name,
      email: user.email,
      avg_score: user.avg_score.to_f.round(2),
      recordings_count: user.call_recordings.completed.count
    }
  end
end
