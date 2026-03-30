class EditLog < ApplicationRecord
  FIELDS   = %w[movie year tags lyrics].freeze
  STATUSES = %w[pending approved rejected].freeze

  belongs_to :song
  belongs_to :user

  validates :field,     inclusion: { in: FIELDS }
  validates :status,    inclusion: { in: STATUSES }
  validates :new_value, presence: true

  validates :user_id, uniqueness: {
    scope: [ :song_id, :field ],
    conditions: -> { where(status: "pending") },
    message: "already has a pending suggestion for this field"
  }

  validate :not_creator
  validate :year_is_numeric, if: -> { field == "year" }
  validate :value_must_change

  scope :pending,  -> { where(status: "pending") }
  scope :approved, -> { where(status: "approved") }
  scope :rejected, -> { where(status: "rejected") }

  def pending?  = status == "pending"
  def approved? = status == "approved"
  def rejected? = status == "rejected"

  def approve!
    ApplicationRecord.transaction do
      apply_to_song!
      update!(status: "approved")
    end
  end

  def reject!
    update!(status: "rejected")
  end

  def current_song_value
    case field
    when "tags" then song.tags.pluck(:name).join(", ")
    else song.public_send(field).to_s
    end
  end

  private

  def value_must_change
    errors.add(:new_value, "is the same as the current value — no change to suggest") if new_value.to_s.strip == old_value.to_s.strip
  end

  def not_creator
    return unless song && user
    errors.add(:base, "Song creator cannot suggest edits to their own song") if song.user == user
  end

  def year_is_numeric
    Integer(new_value)
  rescue ArgumentError, TypeError
    errors.add(:new_value, "must be a valid year")
  end

  def apply_to_song!
    case field
    when "tags"  then apply_tags!
    when "year"  then song.update!(year: new_value.to_i)
    else              song.update!(field => new_value)
    end
  end

  def apply_tags!
    tag_names = new_value.split(",").map(&:strip).reject(&:blank?)
                         .select { |n| n.match?(/\A[a-zA-Z0-9]+\z/) }
    tags = tag_names.map { |name| Tag.find_or_create_by!(name: name) }
    song.tags = tags
  end
end
