class Admin::DashboardsController < Admin::BaseController
  def show
    @stats = {
      songs:         Song.count,
      users:         User.count,
      pending_edits: EditLog.pending.count,
      likes:         Like.count
    }

    @recent_users       = User.order(created_at: :desc).limit(10)
    @recent_songs       = Song.order(created_at: :desc).limit(10)
    @pending_edit_logs  = EditLog.pending.includes(:song, :user).order(created_at: :desc).limit(10)
  end
end
