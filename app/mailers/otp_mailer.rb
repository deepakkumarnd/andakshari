class OtpMailer < ApplicationMailer
  def send_otp(user)
    @user = user
    @otp_code = user.otp_code
    mail(to: @user.email, subject: "Your Andakshari login code: #{@otp_code}")
  end
end
