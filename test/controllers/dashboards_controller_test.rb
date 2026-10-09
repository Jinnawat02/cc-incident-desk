require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "redirects a visitor who isn't signed in to sign-in" do
    get root_path

    assert_redirected_to new_session_path
  end

  test "shows the dashboard to a signed-in user" do
    sign_in_as users(:customer)

    get root_path

    assert_response :success
  end

  test "shows a top bar with the brand, the customer's email and role, and log out" do
    sign_in_as users(:customer)

    get root_path

    assert_select "header" do
      assert_select "a[href=?]", root_path, text: "Incident Desk"
      assert_select "span", "customer@example.com · Customer"
      assert_select "form[action=?] button", session_path, text: "Log out"
      assert_select "form[action=?] input[name=_method][value=delete]", session_path
    end
  end

  test "shows the agent role in the top bar" do
    sign_in_as users(:agent)

    get root_path

    assert_select "header span", "agent@example.com · Agent"
  end
end
