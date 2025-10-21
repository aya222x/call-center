module Invitations
  class AcceptInvitation < ActiveInteraction::Base
    string :invitation_token
    string :password
    string :password_confirmation

    validates :invitation_token, presence: true
    validates :password, presence: true, length: { minimum: 8 }
    validates :password_confirmation, presence: true

    validate :passwords_must_match
    validate :user_must_exist
    validate :invitation_must_be_pending

    def execute
      user = User.find_by(invitation_token: invitation_token)

      if user.accept_invitation!(password)
        user
      else
        errors.merge!(user.errors)
        nil
      end
    end

    private

    def passwords_must_match
      if password.present? && password_confirmation.present? && password != password_confirmation
        errors.add(:password_confirmation, "doesn't match password")
      end
    end

    def user_must_exist
      unless User.exists?(invitation_token: invitation_token)
        errors.add(:invitation_token, "is invalid")
      end
    end

    def invitation_must_be_pending
      user = User.find_by(invitation_token: invitation_token)
      if user && !user.invitation_pending?
        errors.add(:invitation_token, "has already been accepted or is invalid")
      end
    end
  end
end
