require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "redirects visitors to sign-in" do
    get root_path

    assert_redirected_to new_session_path
  end

  test "shows the top bar for a customer" do
    sign_in_as users(:customer)

    get root_path

    assert_response :success
    assert_select ".topbar a.brand[href=?]", root_path, text: "Incident Desk"
    assert_select ".topbar", text: /customer@example\.com · Customer/
    assert_select ".topbar button", "Log out"
  end

  test "shows the top bar for an agent" do
    sign_in_as users(:agent)

    get root_path

    assert_response :success
    assert_select ".topbar", text: /agent@example\.com · Agent/
  end
end
