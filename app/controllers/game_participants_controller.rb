class GameParticipantsController < ApplicationController
  before_action :set_game_room

  def create
    return redirect_to game_room_path(@game_room) if @game_room.participant(current_user)

    role = @game_room.players_full? ? "watcher" : "player"

    if role == "watcher" && @game_room.watchers_full?
      return redirect_to game_room_path(@game_room), alert: "This game room is full."
    end

    @game_room.add_participant!(user: current_user, role: role)
    broadcast_participants
    redirect_to game_room_path(@game_room)
  end

  def destroy
    participant = @game_room.participant(current_user)
    return redirect_to root_path unless participant

    participant.destroy
    broadcast_participants
    redirect_to root_path, notice: "You left the game room."
  end

  private

  def set_game_room
    @game_room = GameRoom.find(params[:game_room_id])
    redirect_to root_path, alert: "Game room not found." unless @game_room
  end

  def broadcast_participants
    Turbo::StreamsChannel.broadcast_replace_to(
      "game_room_#{@game_room.id}",
      target: "participants-frame",
      partial: "game_rooms/participants",
      locals: {
        game_room: @game_room,
        players:   @game_room.players,
        watchers:  @game_room.watchers
      }
    )
  end
end
