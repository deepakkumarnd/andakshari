class Admin::SearchLogsController < Admin::BaseController
  def index
    @pagy, @search_logs = pagy(
      SearchLog.order(created_at: :desc),
      limit: 50
    )
  end
end
