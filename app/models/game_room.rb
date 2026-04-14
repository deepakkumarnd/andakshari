class GameRoom < ApplicationRecord
  MAX_PLAYERS  = 6
  MAX_WATCHERS = 10
  STATUSES     = %w[waiting playing finished].freeze

  belongs_to :user
  has_many :game_participants, dependent: :destroy
  has_many :users, through: :game_participants

  enum :status, STATUSES.index_by(&:itself), default: "waiting"

  def players
    game_participants.where(role: "player")
  end

  def watchers
    game_participants.where(role: "watcher")
  end

  def players_full?
    players.count >= MAX_PLAYERS
  end

  def watchers_full?
    watchers.count >= MAX_WATCHERS
  end

  def participant(user)
    game_participants.find_by(user: user)
  end
end
