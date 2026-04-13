class SongsController < ApplicationController
  skip_before_action :authenticate_user!, only: %i[ index show search search_by_tag search_by_year ]
  before_action :set_song, only: %i[ show edit update destroy like unlike ]

  PAGE_SIZE = 10

  # GET /songs or /songs.json
  def index
    authorize Song
    @pagy, @songs = pagy(Song.all, limit: PAGE_SIZE)
  end

  # POST /songs/search
  def search
    authorize Song
    query = search_query
    results = SongSearchService.search(query)
    song_ids = results.map { |r| r[:song_id] }
    songs_by_id = Song.where(id: song_ids).index_by(&:id)
    all_songs = song_ids.filter_map { |id| songs_by_id[id] }
    @match_by_song_id = results.to_h { |r| [ r[:song_id], { match: r[:match], top_result: r[:top_result] } ] }
    @pagy, @songs = pagy(all_songs, limit: PAGE_SIZE)
    log_search(query, kind: params[:audio].present? ? "voice" : "text", count: all_songs.size)
  end

  # GET /songs/search_by_year?year=1990
  def search_by_year
    authorize Song, :search?
    @year = params[:year].to_i
    @pagy, @songs = pagy(SongSearchService.search_by_year(@year), limit: PAGE_SIZE)
    log_search(@year.to_s, kind: "year", count: @pagy.count)
  end

  # GET /songs/search_by_tag?tag=devotional
  def search_by_tag
    authorize Song, :search?
    @tag = params[:tag].to_s.strip
    @pagy, @songs = pagy(SongSearchService.search_by_tag(@tag), limit: PAGE_SIZE)
    log_search(@tag, kind: "tag", count: @pagy.count)
  end

  # GET /songs/suggest
  def suggest
    authorize Song, :search?
    @suggestions = SongSearchService.suggest(params[:q])
  end

  # GET /songs/1 or /songs/1.json
  def show
    authorize @song
    results = SongSearchService.search("", starting_letter: @song.start_letter)
    song_ids = results.map { |r| r[:song_id] }.reject { |id| id == @song.id }.first(10)
    songs_by_id = Song.where(id: song_ids).index_by(&:id)
    @related_songs = song_ids.filter_map { |id| songs_by_id[id] }
    @my_pending_edits = user_signed_in? ? @song.edit_logs.pending.where(user: current_user).index_by(&:field) : {}
  end

  # GET /songs/new
  def new
    @song = Song.new
    authorize @song
  end

  # GET /songs/1/edit
  def edit
    authorize @song
  end

  # POST /songs or /songs.json
  def create
    @song = Song.new(song_params)
    @song.user = current_user
    authorize @song
    @song.cleanup!

    respond_to do |format|
      if @song.save
        update_tags(@song)
        format.html { redirect_to @song, notice: "Song was successfully created." }
        format.json { render :show, status: :created, location: @song }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /songs/1 or /songs/1.json
  def update
    authorize @song
    @song.assign_attributes(song_params)
    @song.cleanup!

    respond_to do |format|
      if @song.save
        update_tags(@song)
        format.html { redirect_to @song, notice: "Song was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @song }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # POST /songs/1/like
  def like
    current_user.likes.find_or_create_by(song: @song)
    @song.reload
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @song }
    end
  end

  # DELETE /songs/1/unlike
  def unlike
    current_user.likes.find_by(song: @song)&.destroy
    @song.reload
    respond_to do |format|
      format.turbo_stream
      format.html { redirect_to @song }
    end
  end

  # DELETE /songs/1 or /songs/1.json
  def destroy
    authorize @song
    @song.destroy!

    respond_to do |format|
      format.html { redirect_to songs_path, notice: "Song was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_song
      @song = Song.find(params.expect(:id))
    end

    def search_query
      if params[:audio].present?
        Rails.logger.info("SarvamAudioService: transcribing audio, original_filename=#{params[:audio].original_filename}, content_type=#{params[:audio].content_type}, path=#{params[:audio].tempfile.path}")
        begin
          transcript = SarvamAudioService.speech_to_text(params[:audio].tempfile.path, content_type: params[:audio].content_type)
          Rails.logger.info("SarvamAudioService: transcript=#{transcript.inspect}")
          transcript
        rescue => e
          Rails.logger.error("SarvamAudioService error: #{e.message}")
          ""
        end
      else
        Rails.logger.info("SarvamAudioService: no audio param, using q=#{params[:q].inspect}")
        params[:q]
      end
    end

    def update_tags(song)
      tag_list = params[:song]&.[](:tag_list)
      tag_names = Array(tag_list).select { |n| n.is_a?(String) && n.match?(/\A[a-zA-Z0-9]+\z/) }
      tags = tag_names.map { |name| Tag.find_or_create_by!(name: name) }
      song.tags = tags
    end

    # Only allow a list of trusted parameters through.
    def song_params
      params.expect(song: [ :lyrics, :movie, :year ])
    end

    def log_search(query, kind:, count:)
      SearchLog.create!(
        query: query.to_s.strip.truncate(500),
        kind: kind,
        results_count: count,
        ip_address: request.remote_ip
      )
    end
end
