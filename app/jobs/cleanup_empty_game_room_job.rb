class CleanupEmptyGameRoomJob < ApplicationJob
  queue_as :default

  def perform(game_room_id)
    game_room = GameRoom.find_by(id: game_room_id)
    return unless game_room
    game_room.destroy if game_room.game_participants.none?
  end
end
