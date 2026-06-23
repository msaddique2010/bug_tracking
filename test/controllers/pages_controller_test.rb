require "test_helper"

class PagesControllerTest < ActionDispatch::IntegrationTest
  test "should redirect root to login when not signed in" do
    get root_url
    assert_redirected_to new_user_session_url
  end
end
