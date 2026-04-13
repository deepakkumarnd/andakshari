class User < ApplicationRecord
  devise :database_authenticatable, :registerable, :rememberable, :trackable, :validatable

  has_many :songs, dependent: :nullify
  has_many :likes, dependent: :destroy
  has_many :edit_logs, dependent: :destroy
  has_many :edit_log_comments, dependent: :destroy
  has_many :notifications, dependent: :destroy
  has_many :liked_songs, through: :likes, source: :song

  ROLES = %w[user admin].freeze
  enum :role, ROLES.index_by(&:itself), default: "user"

  before_create :assign_username

  ADJECTIVES = %w[
    Silver Golden Crystal Mystic Serene Velvet Indigo Amber Crimson Ivory
    Cosmic Radiant Scarlet Lunar Solar Jade Cobalt Onyx Topaz Aurora
  ].freeze

  NOUNS = %w[
    Melody Raga Tala Swara Lyric Chord Rhythm Harmony Echo Verse
    Sonnet Ballad Cadence Refrain Tempo Octave Overture Nocturne Serenade Aria
  ].freeze

  ADMIN_TITLES = %w[Maestro Curator Conductor Composer Virtuoso].freeze

  def self.generate_username(role = "user")
    loop do
      prefix  = role == "admin" ? ADMIN_TITLES.sample : ADJECTIVES.sample
      suffix  = NOUNS.sample
      number  = rand(10..99)
      name    = "#{prefix}#{suffix}#{number}"
      return name unless User.exists?(username: name)
    end
  end

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

  private

  def assign_username
    self.username ||= self.class.generate_username(role)
  end

  protected

  def password_required?
    false
  end
end
