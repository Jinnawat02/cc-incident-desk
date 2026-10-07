require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "show redirects an unauthenticated visitor to sign in" do
    get root_path

    assert_redirected_to new_session_path
  end

  test "show renders the customer dashboard with a log out button" do
    sign_in_as users(:customer)

    get root_path

    assert_response :success
    assert_select "h1", "My tickets"
    assert_select "header", /customer@example\.com · Customer/
    assert_select "header form[action=?] button", session_path, text: "Log out"
  end

  test "show renders the agent dashboard with a log out button" do
    sign_in_as users(:agent)

    get root_path

    assert_response :success
    assert_select "h1", "All tickets"
    assert_select "header", /agent@example\.com · Agent/
    assert_select "header form[action=?] button", session_path, text: "Log out"
  end

  test "show lists only the customer's own tickets with a new ticket button" do
    sign_in_as users(:customer)

    get root_path

    assert_select "a[href=?]", new_ticket_path, text: "+ New Ticket"
    assert_select "tbody tr", 2
    assert_select "a[href=?]", ticket_path(tickets(:slow_login))
    assert_select "a[href=?]", ticket_path(tickets(:invoice_typo)), count: 0
  end

  test "show does not offer agents a new ticket button" do
    sign_in_as users(:agent)

    get root_path

    assert_select "a[href=?]", new_ticket_path, count: 0
  end
end
