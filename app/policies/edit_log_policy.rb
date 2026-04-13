class EditLogPolicy < ApplicationPolicy
  def new?     = create?
  def create?  = user.present? && record.song.user != user

  def show?
    user.present? && (admin? || creator? || suggester?)
  end

  def edit?    = suggester? && record.pending?
  def update?  = suggester? && record.pending?

  def index?   = admin? || creator?
  def approve? = (admin? || creator?) && record.pending?
  def reject?  = (admin? || creator?) && record.pending?

  private

  def admin?     = user.admin?
  def creator?   = record.song.user == user
  def suggester? = record.user == user
end
