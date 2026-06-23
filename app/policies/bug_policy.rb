class BugPolicy < ApplicationPolicy
  def show?
    # Anyone who can see the project can see its bugs
    ProjectPolicy.new(user, record.project).show?
  end

  def create?
    user.has_role?(:qa) || user.has_role?(:manager)
  end

  def new?
    create?
  end

  def update?
    # Creator of the bug, or the manager of the project
    record.user_id == user.id || (user.has_role?(:manager) && record.project.user_id == user.id)
  end

  def edit?
    update?
  end

  def destroy?
    # Developer cannot delete a bug
    return false if user.has_role?(:developer)

    # Creator of the bug, or the manager of the project
    record.user_id == user.id || (user.has_role?(:manager) && record.project.user_id == user.id)
  end

  def assign?
    # Developer can assign a bug to themselves if they belong to the project
    user.has_role?(:developer) && record.project.users.include?(user)
  end

  def resolve?
    # Developer can resolve the bug if it is assigned to them
    user.has_role?(:developer) && record.developer_id == user.id
  end

  class Scope < ApplicationPolicy::Scope
    def resolve
      scope.all
    end
  end
end
