class Notification < ApplicationRecord
  TYPES = %w[info success danger].freeze

  belongs_to :user

  validates :notification_type, inclusion: { in: TYPES }
  validates :message, presence: true
  validates :url,     presence: true
end
