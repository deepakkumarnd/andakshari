class VoiceChannel < ApplicationCable::Channel
  def subscribed
    game_room = GameRoom.find_by(id: params[:game_room_id])
    reject and return unless game_room && current_user

    # Room-wide stream for presence announcements
    stream_from "voice_room_#{game_room.id}"
    # Per-user stream for point-to-point signaling
    stream_from "voice_user_#{current_user.id}"
  end

  # Relay WebRTC offer/answer/ICE to a specific user
  def signal(data)
    ActionCable.server.broadcast(
      "voice_user_#{data['to']}",
      { type: data['type'], from: current_user.id, sdp: data['sdp'], candidate: data['candidate'] }
    )
  end

  # Broadcast presence so existing users initiate offers to the new arrival
  def announce(_data)
    ActionCable.server.broadcast(
      "voice_room_#{params[:game_room_id]}",
      { type: "user_joined", user_id: current_user.id, username: current_user.username }
    )
  end

  # Broadcast mute state so others can reflect it in the UI
  def mute_state(data)
    ActionCable.server.broadcast(
      "voice_room_#{params[:game_room_id]}",
      { type: "mute_state", user_id: current_user.id, muted: data['muted'] }
    )
  end
end
