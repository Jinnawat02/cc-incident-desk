require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  test "redirects visitors to sign-in" do
    get root_path

    assert_redirected_to new_session_path
  end

  test "shows the top bar for a customer" do
    sign_in_as users(:customer)

    get root_path

    assert_response :success
    assert_select "header a[href=?]", root_path, text: "Incident Desk"
    assert_select "header", text: /customer@example\.com · Customer/
    assert_select "header form[action=?] button", session_path, text: "Log out"
  end

  test "shows the agent role in the top bar" do
    sign_in_as users(:agent)

    get root_path

    assert_select "header", text: /agent@example\.com · Agent/
  end
end
