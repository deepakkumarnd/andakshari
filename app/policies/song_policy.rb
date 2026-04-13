class SongPolicy < ApplicationPolicy
  def index?
    true
  end

  def search?
    true
  end

  def show?
    true
  end

  def create?
    user.present?
  end

  def update?
    user.present? && record.user == user
  end

  def destroy?
    user.present? && record.user == user
  end

  def like?
    user.present?
  end

  def suggest_edit?
    user.present? && record.user != user
  end
end
