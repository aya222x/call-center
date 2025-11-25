# == Schema Information
#
# Table name: teams
#
#  id             :integer          not null, primary key
#  deactivated_at :datetime
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#  department_id  :integer          not null
#  supervisor_id  :integer
#
# Indexes
#
#  index_teams_on_deactivated_at         (deactivated_at)
#  index_teams_on_department_id          (department_id)
#  index_teams_on_department_id_and_name (department_id,name) UNIQUE
#  index_teams_on_supervisor_id          (supervisor_id)
#
# Foreign Keys
#
#  department_id  (department_id => departments.id)
#  supervisor_id  (supervisor_id => users.id)
#
class Team < ApplicationRecord
  # Audit trail
  audited

  # Associations
  belongs_to :department
  belongs_to :supervisor, class_name: 'User', optional: true
  has_many :users, dependent: :nullify
  has_many :call_recordings, through: :users

  # Validations
  validates :name, presence: true,
                   uniqueness: { scope: :department_id, case_sensitive: false },
                   length: { minimum: 2, maximum: 100 }
  validates :department_id, presence: true

  # Scopes
  scope :active, -> { where(deactivated_at: nil) }
  scope :for_department, ->(department_id) { where(department_id: department_id) }

  def active?
    deactivated_at.nil?
  end

  def deactivate!
    update!(deactivated_at: Time.current)
  end

  def activate!
    update!(deactivated_at: nil)
  end
end
