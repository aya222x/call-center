# == Schema Information
#
# Table name: users
#
#  id                     :integer          not null, primary key
#  email                  :string           not null
#  name                   :string           not null
#  owner                  :boolean          default(FALSE), not null
#  password_digest        :string           not null
#  reset_password_digest  :string
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email  (email) UNIQUE
#
class User < ApplicationRecord
  has_secure_password validations: false

  # Audit trail for tracking changes
  audited

  # Associations
  has_many :refresh_tokens, dependent: :destroy
  has_one_attached :avatar

  # Validations
  validates :email, presence: true,
                    uniqueness: { case_sensitive: false },
                    format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :name, presence: true, length: { minimum: 2, maximum: 100 }
  validates :password, presence: true, length: { minimum: 8 }, if: :password_required?
  validates :password, length: { minimum: 8 }, allow_blank: true, if: :password_present?
  validates :avatar, content_type: { in: %w[image/png image/jpg image/jpeg image/gif],
                                     message: "must be a PNG, JPG, or GIF image" },
                     size: { less_than: 5.megabytes, message: "must be less than 5MB" },
                     if: -> { avatar.attached? }

  # Callbacks
  before_save :normalize_email

  # Ransack configuration - only allow searching on safe attributes
  def self.ransackable_attributes(auth_object = nil)
    %w[id name email owner created_at updated_at]
  end

  # Ransack associations - empty for now, add as needed
  def self.ransackable_associations(auth_object = nil)
    []
  end

  # Password reset methods
  def generate_password_reset_token
    self.reset_password_token = SecureRandom.urlsafe_base64
    self.reset_password_digest = BCrypt::Password.create(reset_password_token)
    self.reset_password_sent_at = Time.current
    save!
    reset_password_token
  end

  def password_reset_expired?
    return true if reset_password_sent_at.nil?

    reset_password_sent_at < 2.hours.ago
  end

  def clear_password_reset
    self.reset_password_token = nil
    self.reset_password_digest = nil
    self.reset_password_sent_at = nil
    save!
  end

  # Invitation methods
  def generate_invitation_token
    self.invitation_token = SecureRandom.urlsafe_base64
    self.invitation_sent_at = Time.current
    self.invitation_accepted_at = nil
    save!
    invitation_token
  end

  def invitation_pending?
    invitation_sent_at.present? && invitation_accepted_at.nil?
  end

  def invitation_accepted?
    invitation_accepted_at.present?
  end

  def accept_invitation!(password)
    self.password = password
    self.password_confirmation = password
    self.invitation_accepted_at = Time.current
    self.invitation_token = nil
    save!
  end

  def active?
    password_digest.present?
  end

  private

  def normalize_email
    self.email = email.downcase.strip if email.present?
  end

  def password_required?
    # Password required when accepting invitation or creating without invitation
    !persisted? && !invitation_pending?
  end

  def password_present?
    password.present?
  end
end
