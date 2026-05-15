class GameRoomsController < ApplicationController
  def new; end

  def create
    @game_room = GameRoom.create!(user: current_user)
    @game_room.add_participant!(user: current_user, role: "player")
    redirect_to game_room_path(@game_room)
  end

  def show
    @game_room = GameRoom.find(params[:id])
    return render :not_found, status: :not_found unless @game_room

    @players  = @game_room.players
    @watchers = @game_room.watchers
    @me       = @game_room.participant(current_user)
  end
end
