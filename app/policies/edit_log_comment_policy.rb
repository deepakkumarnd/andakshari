class EditLogCommentPolicy < ApplicationPolicy
  def create?
    user.present? && (creator? || suggester?)
  end

  private

  def creator?   = record.edit_log.song.user == user
  def suggester? = record.edit_log.user == user
end
