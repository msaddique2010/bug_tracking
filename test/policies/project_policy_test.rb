require 'test_helper'

class ProjectPolicyTest < ActiveSupport::TestCase
  setup do
    @manager = users(:one)
    @developer = users(:two)
    @qa = users(:three)
    @project = projects(:one)
  end

  def test_scope
    scope = ProjectPolicy::Scope.new(@manager, Project).resolve
    assert_includes scope, @project

    # Assign developer to project
    @project.users << @developer
    scope_dev = ProjectPolicy::Scope.new(@developer, Project).resolve
    assert_includes scope_dev, @project
  end

  def test_show
    assert ProjectPolicy.new(@manager, @project).show?
    assert ProjectPolicy.new(@qa, @project).show?

    # Dev only if assigned
    refute ProjectPolicy.new(@developer, @project).show?
    @project.users << @developer
    assert ProjectPolicy.new(@developer, @project).show?
  end

  def test_create
    assert ProjectPolicy.new(@manager, Project.new).create?
    refute ProjectPolicy.new(@developer, Project.new).create?
    refute ProjectPolicy.new(@qa, Project.new).create?
  end

  def test_update
    assert ProjectPolicy.new(@manager, @project).update?
    refute ProjectPolicy.new(@qa, @project).update?
    
    # Another manager cannot update
    other_manager = User.create!(name: "Other Manager", email: "other@mgr.com", password: "password", user_type: "manager")
    refute ProjectPolicy.new(other_manager, @project).update?
  end

  def test_destroy
    assert ProjectPolicy.new(@manager, @project).destroy?
    refute ProjectPolicy.new(@developer, @project).destroy?
  end
end
