class ProjectPolicy < ApplicationPolicy
  def index?
    true
  end

  def show?
    user.has_role?(:qa) ||
      (user.has_role?(:manager) && record.user_id == user.id) ||
      (user.has_role?(:developer) && record.users.include?(user))
  end

  def create?
    user.has_role?(:manager)
  end

  def new?
    create?
  end

  def update?
    user.has_role?(:manager) && record.user_id == user.id
  end

  def edit?
    update?
  end

  def destroy?
    user.has_role?(:manager) && record.user_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      if user.has_role?(:manager)
        scope.where(user_id: user.id)
      elsif user.has_role?(:qa)
        scope.all
      elsif user.has_role?(:developer)
        scope.joins(:project_users).where(project_users: { user_id: user.id }).distinct
      else
        scope.none
      end
    end
  end
end
