class GameRoomsController < ApplicationController
  def new
    @game_room = GameRoom.new
  end

  def create
    @game_room = GameRoom.new(user: current_user)
    if @game_room.save
      # Creator joins as a player automatically
      @game_room.game_participants.create!(user: current_user, role: "player")
      redirect_to @game_room
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @game_room = GameRoom.find(params[:id])
    @players   = @game_room.players.includes(:user)
    @watchers  = @game_room.watchers.includes(:user)
    @me        = @game_room.participant(current_user)
  end
end
