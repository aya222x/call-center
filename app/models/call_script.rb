# == Schema Information
#
# Table name: call_scripts
#
#  id            :integer          not null, primary key
#  active        :boolean          default(TRUE), not null
#  call_type     :integer          default("sales"), not null
#  content       :text             not null
#  name          :string           not null
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#  department_id :integer          not null
#
# Indexes
#
#  index_call_scripts_on_active         (active)
#  index_call_scripts_on_call_type      (call_type)
#  index_call_scripts_on_department_id  (department_id)
#
# Foreign Keys
#
#  department_id  (department_id => departments.id)
#
class CallScript < ApplicationRecord
  # Audit trail
  audited

  # Enums
  enum :call_type, { sales: 0, support: 1, survey: 2, other: 3 }

  # Associations
  belongs_to :department
  has_many :call_recordings, dependent: :nullify

  # Validations
  validates :name, presence: true,
                   length: { minimum: 3, maximum: 200 }
  validates :call_type, presence: true
  validates :content, presence: true,
                      length: { minimum: 10 }
  validates :department_id, presence: true

  # Scopes
  scope :active, -> { where(active: true) }
  scope :for_department, ->(department_id) { where(department_id: department_id) }
  scope :by_call_type, ->(call_type) { where(call_type: call_type) }

  def deactivate!
    update!(active: false)
  end

  def activate!
    update!(active: true)
  end
end
