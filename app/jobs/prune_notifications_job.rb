class PruneNotificationsJob < ApplicationJob
  queue_as :default

  def perform
    Notification.where("created_at < ?", 1.month.ago).delete_all
  end
end
