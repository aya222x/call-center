# == Schema Information
#
# Table name: departments
#
#  id             :integer          not null, primary key
#  deactivated_at :datetime
#  name           :string           not null
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
# Indexes
#
#  index_departments_on_deactivated_at  (deactivated_at)
#  index_departments_on_name            (name) UNIQUE
#
class Department < ApplicationRecord
  # Audit trail
  audited

  # Associations
  has_many :teams, dependent: :destroy
  has_many :call_scripts, dependent: :destroy
  has_many :users, through: :teams

  # Validations
  validates :name, presence: true,
                   uniqueness: { case_sensitive: false },
                   length: { minimum: 2, maximum: 100 }

  # Scopes
  scope :active, -> { where(deactivated_at: nil) }

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
