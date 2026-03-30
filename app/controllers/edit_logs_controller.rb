class EditLogsController < ApplicationController
  before_action :set_song
  before_action :set_edit_log, only: %i[show approve reject]

  def index
    @edit_log = EditLog.new(song: @song)
    authorize @edit_log, :index?
    @edit_logs = @song.edit_logs.pending.includes(:user).order(created_at: :asc)
  end

  def show
    authorize @edit_log
  end

  def new
    @edit_log = EditLog.new(song: @song, field: params[:field])
    @edit_log.old_value = current_field_value(@edit_log.field)
    authorize @edit_log
  end

  def create
    @edit_log = EditLog.new(edit_log_params)
    @edit_log.song = @song
    @edit_log.user = current_user
    authorize @edit_log

    if @edit_log.save
      redirect_to song_path(@song), notice: "Your suggestion has been submitted."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def approve
    authorize @edit_log
    @edit_log.approve!
    redirect_to song_edit_logs_path(@song), notice: "Edit approved and applied."
  rescue ActiveRecord::RecordInvalid => e
    redirect_to song_edit_logs_path(@song), alert: "Could not apply edit: #{e.message}"
  rescue Pundit::NotAuthorizedError
    redirect_to song_path(@song), alert: "Not authorized."
  end

  def reject
    authorize @edit_log
    @edit_log.reject!
    redirect_to song_edit_logs_path(@song), notice: "Suggestion rejected."
  end

  private

  def set_song
    @song = Song.find(params[:song_id])
  end

  def set_edit_log
    @edit_log = @song.edit_logs.find(params[:id])
  end

  def edit_log_params
    params.expect(edit_log: [ :field, :old_value, :new_value ])
  end

  def current_field_value(field)
    return nil if field.blank?
    case field
    when "tags" then @song.tags.pluck(:name).join(", ")
    else @song.public_send(field).to_s
    end
  end
end
