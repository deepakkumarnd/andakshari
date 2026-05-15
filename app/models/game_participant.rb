class GameParticipant
  ROLES = %w[player watcher].freeze

  attr_reader :user, :game_room, :role

  def initialize(user:, game_room:, role:)
    @user      = user
    @game_room = game_room
    @role      = role
  end

  def id; user.id; end

  def player?;  role == "player";  end
  def watcher?; role == "watcher"; end

  def destroy
    game_room.remove_participant!(user: user)
    CleanupEmptyGameRoomJob.set(wait: 1.minute).perform_later(game_room.id)
  end
end
