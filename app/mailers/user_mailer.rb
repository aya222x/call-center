class UserMailer < ApplicationMailer
  def reset_password_instructions(user)
    @user = user
    @reset_url = password_reset_url(token: user.reset_password_token)

    mail(
      to: user.email,
      subject: "Password Reset Instructions"
    )
  end

  def invitation_email(user, token)
    @user = user
    @invitation_url = accept_invitation_url(token: token)

    mail(
      to: user.email,
      subject: "You've been invited to join Starter App"
    )
  end
end
