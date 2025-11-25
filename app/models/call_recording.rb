# == Schema Information
#
# Table name: call_recordings
#
#  id               :integer          not null, primary key
#  call_date        :date             not null
#  customer_name    :string
#  customer_phone   :string
#  duration_seconds :integer
#  error_message    :text
#  language         :integer          default("russian"), not null
#  status           :integer          default("uploaded"), not null
#  transcript       :text
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  call_script_id   :integer          not null
#  user_id          :integer          not null
#
# Indexes
#
#  index_call_recordings_on_call_date              (call_date)
#  index_call_recordings_on_call_script_id         (call_script_id)
#  index_call_recordings_on_language               (language)
#  index_call_recordings_on_status                 (status)
#  index_call_recordings_on_user_id                (user_id)
#  index_call_recordings_on_user_id_and_call_date  (user_id,call_date)
#
# Foreign Keys
#
#  call_script_id  (call_script_id => call_scripts.id)
#  user_id         (user_id => users.id)
#
class CallRecording < ApplicationRecord
  # Audit trail
  audited

  # Enums
  enum :status, { uploaded: 0, transcribing: 1, analyzing: 2, completed: 3, failed: 4 }
  enum :language, { kyrgyz: 0, russian: 1, english: 2 }

  # Associations
  belongs_to :user
  belongs_to :call_script
  has_one :evaluation, dependent: :destroy
  has_one_attached :audio_file

  # Validations
  validates :user_id, presence: true
  validates :call_script_id, presence: true
  validates :status, presence: true
  validates :customer_name, length: { maximum: 200 }, allow_nil: true
  validates :customer_phone, length: { maximum: 50 }, allow_nil: true

  # Scopes
  scope :for_user, ->(user_id) { where(user_id: user_id) }
  scope :for_team, ->(team_id) { joins(:user).where(users: { team_id: team_id }) }
  scope :for_department, ->(department_id) {
    joins(user: { team: :department }).where(teams: { department_id: department_id })
  }
  scope :recent, -> { order(created_at: :desc) }
  scope :by_status, ->(status) { where(status: status) }
  scope :by_language, ->(language) { where(language: language) }
  scope :date_range, ->(start_date, end_date) { where(call_date: start_date..end_date) }

  def duration_formatted
    return '0:00' if duration_seconds.nil?

    minutes = duration_seconds / 60
    seconds = duration_seconds % 60
    format('%d:%02d', minutes, seconds)
  end

  def can_be_processed?
    uploaded?
  end
end
