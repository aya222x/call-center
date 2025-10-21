module Invitations
  class SendInvitation < ActiveInteraction::Base
    object :current_user, class: User
    string :email
    string :name

    validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
    validates :name, presence: true, length: { minimum: 2, maximum: 100 }

    validate :user_must_be_owner
    validate :email_must_not_exist

    def execute
      user = User.new(
        email: email.downcase.strip,
        name: name,
        owner: false
      )

      if user.save(validate: false)
        token = user.generate_invitation_token
        UserMailer.invitation_email(user, token).deliver_later
        user
      else
        errors.merge!(user.errors)
        nil
      end
    end

    private

    def user_must_be_owner
      errors.add(:current_user, "must be an owner") unless current_user&.owner?
    end

    def email_must_not_exist
      errors.add(:email, "already exists") if User.exists?(email: email.downcase.strip)
    end
  end
end
