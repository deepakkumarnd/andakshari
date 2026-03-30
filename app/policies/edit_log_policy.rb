class EditLogPolicy < ApplicationPolicy
  def new?     = create?
  def create?  = user.present? && record.song.user != user

  def show?
    user.present? && (creator? || suggester?)
  end

  def edit?    = suggester? && record.pending?
  def update?  = suggester? && record.pending?

  def index?   = creator?
  def approve? = creator? && record.pending?
  def reject?  = creator? && record.pending?

  private

  def creator?   = record.song.user == user
  def suggester? = record.user == user
end
