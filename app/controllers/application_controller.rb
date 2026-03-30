class ApplicationController < ActionController::Base
  include Pundit::Authorization
  include Pagy::Method

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern
  before_action :authenticate_user!
  before_action :load_notifications

  private

  def load_notifications
    @notifications = user_signed_in? ? current_user.notifications.order(created_at: :desc).limit(20) : []
  end
end
