class NotificationsController < ApplicationController
  def show
    notification = current_user.notifications.find(params[:id])
    url = notification.url
    notification.destroy
    redirect_to url
  end
end
