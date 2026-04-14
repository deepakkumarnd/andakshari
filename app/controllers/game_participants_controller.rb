class GameParticipantsController < ApplicationController
  before_action :set_game_room

  def create
    return redirect_to @game_room if @game_room.participant(current_user)

    role = @game_room.players_full? ? "watcher" : "player"

    if role == "watcher" && @game_room.watchers_full?
      return redirect_to @game_room, alert: "This game room is full."
    end

    @game_room.game_participants.create!(user: current_user, role: role)
    broadcast_participants
    redirect_to @game_room
  end

  private

  def set_game_room
    @game_room = GameRoom.find(params[:game_room_id])
  end

  def broadcast_participants
    Turbo::StreamsChannel.broadcast_replace_to(
      "game_room_#{@game_room.id}",
      target: "participants-frame",
      partial: "game_rooms/participants",
      locals: {
        game_room: @game_room,
        players:   @game_room.players.includes(:user),
        watchers:  @game_room.watchers.includes(:user)
      }
    )
  end
end
