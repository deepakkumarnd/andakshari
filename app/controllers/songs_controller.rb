class SongsController < ApplicationController
  before_action :set_song, only: %i[ show edit update destroy ]

  # GET /songs or /songs.json
  def index
    @songs = Song.all
  end

  # POST /songs/search
  def search
    results = SongSearchService.search(search_query)
    song_ids = results.map { |r| r[:song_id] }
    songs_by_id = Song.where(id: song_ids).index_by(&:id)
    @songs = song_ids.filter_map { |id| songs_by_id[id] }
    @match_by_song_id = results.to_h { |r| [ r[:song_id], { match: r[:match], top_result: r[:top_result] } ] }
  end

  # GET /songs/1 or /songs/1.json
  def show
    results = SongSearchService.search("", starting_letter: @song.start_letter)
    song_ids = results.map { |r| r[:song_id] }.reject { |id| id == @song.id }.first(10)
    songs_by_id = Song.where(id: song_ids).index_by(&:id)
    @related_songs = song_ids.filter_map { |id| songs_by_id[id] }
  end

  # GET /songs/new
  def new
    @song = Song.new
  end

  # GET /songs/1/edit
  def edit
  end

  # POST /songs or /songs.json
  def create
    @song = Song.new(song_params)
    @song.cleanup!

    respond_to do |format|
      if @song.save
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
    @song.assign_attributes(song_params)
    @song.cleanup!

    respond_to do |format|
      if @song.save
        format.html { redirect_to @song, notice: "Song was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @song }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @song.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /songs/1 or /songs/1.json
  def destroy
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

    # Only allow a list of trusted parameters through.
    def song_params
      params.expect(song: [ :lyrics, :movie, :year ])
    end
end
