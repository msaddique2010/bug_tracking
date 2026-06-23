require "test_helper"

class BugsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @qa = users(:three)
    sign_in @qa
    @project = projects(:one)
    @bug = bugs(:one)
  end

  test "should get index" do
    get project_bugs_url(@project)
    assert_response :success
  end

  test "should get new" do
    get new_project_bug_url(@project)
    assert_response :success
  end

  test "should create bug" do
    assert_difference("Bug.count") do
      post project_bugs_url(@project), params: { bug: { bug_type: "bug", deadline: "2026-12-30", status: "new", title: "Brand New Unique Bug Title" } }
    end

    assert_redirected_to project_bugs_url(@project)
  end

  test "should show bug" do
    get project_bug_url(@project, @bug)
    assert_response :success
  end

  test "should get edit" do
    get edit_project_bug_url(@project, @bug)
    assert_response :success
  end

  test "should update bug" do
    patch project_bug_url(@project, @bug), params: { bug: { title: "Updated Bug Title" } }
    assert_redirected_to project_bug_url(@project, @bug)
  end

  test "should destroy bug" do
    assert_difference("Bug.count", -1) do
      delete project_bug_url(@project, @bug)
    end

    assert_redirected_to project_bugs_url(@project)
  end
end
