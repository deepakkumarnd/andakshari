class GameParticipant < ApplicationRecord
  ROLES = %w[player watcher].freeze

  belongs_to :game_room
  belongs_to :user

  enum :role, ROLES.index_by(&:itself)

  validates :role, inclusion: { in: ROLES }
end
