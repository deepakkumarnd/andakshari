class EditLogCommentsController < ApplicationController
  before_action :set_song
  before_action :set_edit_log

  def create
    @comment = @edit_log.edit_log_comments.new(body: params.expect(edit_log_comment: :body)[:body])
    @comment.user = current_user
    authorize @comment

    if @comment.save
      redirect_to song_edit_log_path(@song, @edit_log, anchor: "comment-#{@comment.id}"),
                  notice: "Comment added."
    else
      redirect_to song_edit_log_path(@song, @edit_log), alert: @comment.errors.full_messages.to_sentence
    end
  end

  private

  def set_song
    @song = Song.find(params[:song_id])
  end

  def set_edit_log
    @edit_log = @song.edit_logs.find(params[:edit_log_id])
  end
end
