class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable

  has_many :songs, dependent: :nullify
  has_many :likes, dependent: :destroy
  has_many :edit_logs, dependent: :destroy
  has_many :liked_songs, through: :likes, source: :song

  OTP_VALIDITY = 10.minutes

  def generate_otp!
    update!(
      otp_code: SecureRandom.random_number(10**6).to_s.rjust(6, "0"),
      otp_sent_at: Time.current
    )
  end

  def verify_otp(code)
    return false if otp_code.blank? || otp_sent_at.blank?
    return false if Time.current - otp_sent_at > OTP_VALIDITY
    return false unless ActiveSupport::SecurityUtils.secure_compare(otp_code.to_s, code.to_s)

    clear_otp!
    true
  end

  def clear_otp!
    update!(otp_code: nil, otp_sent_at: nil)
  end

  protected

  def password_required?
    false
  end
end
