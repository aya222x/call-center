module Invitations
  class ResendInvitation < ActiveInteraction::Base
    object :current_user, class: User
    integer :user_id

    validates :user_id, presence: true

    validate :current_user_must_be_owner
    validate :invited_user_must_exist
    validate :invitation_must_be_pending

    def execute
      user = User.find(user_id)
      token = user.generate_invitation_token
      UserMailer.invitation_email(user, token).deliver_later
      user
    end

    private

    def current_user_must_be_owner
      errors.add(:current_user, "must be an owner") unless current_user&.owner?
    end

    def invited_user_must_exist
      errors.add(:user_id, "user not found") unless User.exists?(user_id)
    end

    def invitation_must_be_pending
      user = User.find_by(id: user_id)
      if user && !user.invitation_pending?
        errors.add(:base, "user has already accepted invitation or was not invited")
      end
    end
  end
end
