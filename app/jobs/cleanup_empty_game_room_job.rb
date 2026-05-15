class CleanupEmptyGameRoomJob < ApplicationJob
  queue_as :default

  # With game_room_id: destroy that specific room if empty (called after explicit leave).
  # Without arguments: sweep all empty rooms (called by recurring scheduler).
  def perform(game_room_id = nil)
    if game_room_id
      game_room = GameRoom.find(game_room_id)
      game_room&.destroy if game_room&.participants_empty?
    else
      GameRoom.all_empty.each(&:destroy)
    end
  end
end
