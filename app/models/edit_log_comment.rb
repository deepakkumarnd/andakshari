class EditLogComment < ApplicationRecord
  belongs_to :edit_log
  belongs_to :user

  validates :body, presence: true
end
