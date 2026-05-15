class GameParticipant < ApplicationRecord
  ROLES = %w[player watcher].freeze

  belongs_to :game_room
  belongs_to :user

  enum :role, ROLES.index_by(&:itself)

  validates :role, inclusion: { in: ROLES }

  after_destroy :schedule_cleanup

  private

  def schedule_cleanup
    CleanupEmptyGameRoomJob.set(wait: 1.minute).perform_later(game_room.id)
  end
end
