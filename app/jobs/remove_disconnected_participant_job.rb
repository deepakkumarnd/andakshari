class RemoveDisconnectedParticipantJob < ApplicationJob
  queue_as :default

  def perform(game_room_id, user_id, disconnected_at)
    game_room = GameRoom.find(game_room_id)
    return unless game_room

    user = User.find_by(id: user_id)
    return unless user && game_room.participant(user)

    last_connected  = game_room.last_connected_at(user: user)
    disconnect_time = Time.parse(disconnected_at)

    # User reconnected after this disconnect — leave them in the room
    return if last_connected && last_connected > disconnect_time

    game_room.remove_participant!(user: user)

    Turbo::StreamsChannel.broadcast_replace_to(
      "game_room_#{game_room.id}",
      target: "participants-frame",
      partial: "game_rooms/participants",
      locals: {
        game_room: game_room,
        players:   game_room.players,
        watchers:  game_room.watchers
      }
    )

    CleanupEmptyGameRoomJob.set(wait: 1.minute).perform_later(game_room.id)
  end
end
