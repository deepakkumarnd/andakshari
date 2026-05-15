class VoiceChannel < ApplicationCable::Channel
  def subscribed
    game_room = GameRoom.find(params[:game_room_id])
    reject and return unless game_room && current_user

    stream_from "voice_room_#{game_room.id}"
    stream_from "voice_user_#{current_user.id}"

    game_room.record_connection(user: current_user)
  end

  def unsubscribed
    game_room = GameRoom.find(params[:game_room_id])
    return unless game_room && current_user

    RemoveDisconnectedParticipantJob
      .set(wait: 1.minute)
      .perform_later(game_room.id, current_user.id, Time.current.iso8601)
  end

  def signal(data)
    ActionCable.server.broadcast(
      "voice_user_#{data['to']}",
      { type: data['type'], from: current_user.id, sdp: data['sdp'], candidate: data['candidate'] }
    )
  end

  def announce(_data)
    ActionCable.server.broadcast(
      "voice_room_#{params[:game_room_id]}",
      { type: "user_joined", user_id: current_user.id, username: current_user.username }
    )
  end

  def mute_state(data)
    ActionCable.server.broadcast(
      "voice_room_#{params[:game_room_id]}",
      { type: "mute_state", user_id: current_user.id, muted: data['muted'] }
    )
  end
end
