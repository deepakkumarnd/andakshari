class NotificationService
  def self.notify(user:, type:, message:, url:)
    return unless user.present?

    Notification.create!(
      user: user,
      notification_type: type,
      message: message,
      url: url
    )
  end
end
