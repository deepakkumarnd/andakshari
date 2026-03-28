class Like < ApplicationRecord
  belongs_to :user
  belongs_to :song, counter_cache: true

  validates :user_id, uniqueness: { scope: :song_id }
end
