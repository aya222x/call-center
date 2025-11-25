# == Schema Information
#
# Table name: evaluations
#
#  id                      :integer          not null, primary key
#  overall_score           :decimal(5, 2)    not null
#  politeness_score        :decimal(5, 2)
#  recommendations         :text
#  resolution_speed_score  :decimal(5, 2)
#  script_adherence_score  :decimal(5, 2)
#  success_score           :decimal(5, 2)
#  terminology_score       :decimal(5, 2)
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  call_recording_id       :integer          not null
#
# Indexes
#
#  index_evaluations_on_call_recording_id  (call_recording_id) UNIQUE
#  index_evaluations_on_overall_score      (overall_score)
#
# Foreign Keys
#
#  call_recording_id  (call_recording_id => call_recordings.id)
#
class Evaluation < ApplicationRecord
  # Audit trail
  audited

  # Associations
  belongs_to :call_recording

  # Validations
  validates :call_recording_id, presence: true
  validates :overall_score, presence: true,
                            numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }
  validates :script_adherence_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :politeness_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :resolution_speed_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :terminology_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true
  validates :success_score, numericality: { greater_than_or_equal_to: 0, less_than_or_equal_to: 100 }, allow_nil: true

  def score_color
    case overall_score
    when 80..100 then 'green'
    when 60...80 then 'yellow'
    when 40...60 then 'orange'
    else 'red'
    end
  end

  def score_label
    case overall_score
    when 90..100 then 'Excellent'
    when 80...90 then 'Good'
    when 70...80 then 'Satisfactory'
    when 60...70 then 'Needs Improvement'
    else 'Poor'
    end
  end

  def all_scores_present?
    script_adherence_score.present? &&
      politeness_score.present? &&
      resolution_speed_score.present? &&
      terminology_score.present? &&
      success_score.present?
  end

  def calculate_overall_score
    scores = [
      script_adherence_score,
      politeness_score,
      resolution_speed_score,
      terminology_score,
      success_score
    ].compact

    return 0.0 if scores.empty?

    (scores.sum / scores.size.to_f).round(2)
  end
end
