require 'test_helper'

class BugPolicyTest < ActiveSupport::TestCase
  setup do
    @manager = users(:one)
    @developer = users(:two)
    @qa = users(:three)
    @project = projects(:one)
    @bug = bugs(:one)
  end

  def test_scope
    scope = BugPolicy::Scope.new(@qa, Bug).resolve
    assert_includes scope, @bug
  end

  def test_show
    assert BugPolicy.new(@manager, @bug).show?
    assert BugPolicy.new(@qa, @bug).show?
  end

  def test_create
    assert BugPolicy.new(@qa, Bug.new(project: @project)).create?
    assert BugPolicy.new(@manager, Bug.new(project: @project)).create?
    refute BugPolicy.new(@developer, Bug.new(project: @project)).create?
  end

  def test_update
    assert BugPolicy.new(@qa, @bug).update?
    refute BugPolicy.new(@developer, @bug).update?
  end

  def test_destroy
    assert BugPolicy.new(@qa, @bug).destroy?
    refute BugPolicy.new(@developer, @bug).destroy?
  end

  def test_assign_and_resolve
    bug_policy = BugPolicy.new(@developer, @bug)
    
    # Cannot assign if not member of project
    refute bug_policy.assign?
    
    # Assign developer to project
    @project.users << @developer
    assert bug_policy.assign?

    # Resolve only if assigned
    refute bug_policy.resolve?
    @bug.update!(developer: @developer)
    assert bug_policy.resolve?
  end
end
