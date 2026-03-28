class SongPolicy < ApplicationPolicy
  def index?
    true
  end

  def search?
    true
  end

  def show?
    user.present?
  end

  def create?
    user.present?
  end

  def update?
    record.user == user
  end

  def destroy?
    record.user == user
  end
end
