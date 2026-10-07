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

  test "show lists every ticket for an agent with the story columns" do
    sign_in_as users(:agent)

    get root_path

    assert_select "thead th" do |headers|
      assert_equal [ "ID", "Title", "Customer", "Severity", "Status", "Assignee", "Created at" ], headers.map(&:text)
    end
    assert_select "tbody tr", Ticket.count
    assert_select "##{ActionView::RecordIdentifier.dom_id(tickets(:invoice_typo))}", /other@example\.com/
  end

  test "show offers status filters with counts and marks all as active by default" do
    sign_in_as users(:agent)

    get root_path

    assert_select "nav[aria-label=?] a", "Filter by status", 4
    assert_select "a.pill.is-active[aria-current=page]", "All (4)"
    assert_select "a.pill[href=?]", root_path(status: "open"), "Open (2)"
    assert_select "a.pill[href=?]", root_path(status: "in_progress"), "In Progress (1)"
    assert_select "a.pill[href=?]", root_path(status: "resolved"), "Resolved (1)"
  end

  test "show filters an agent's list by status" do
    sign_in_as users(:agent)

    get root_path(status: "open")

    assert_select "a.pill.is-active", "Open (2)"
    assert_select "tbody tr", 2
    assert_select "a[href=?]", ticket_path(tickets(:checkout_error))
    assert_select "a[href=?]", ticket_path(tickets(:slow_login))
    assert_select "a[href=?]", ticket_path(tickets(:invoice_typo)), count: 0
  end

  test "show treats an unknown status filter as all" do
    sign_in_as users(:agent)

    get root_path(status: "bogus")

    assert_response :success
    assert_select "a.pill.is-active", "All (4)"
    assert_select "tbody tr", Ticket.count
  end

  test "show highlights high and urgent tickets for an agent" do
    sign_in_as users(:agent)

    get root_path

    assert_select "tr.row-urgent##{ActionView::RecordIdentifier.dom_id(tickets(:checkout_error))}"
    assert_select "tr.row-high##{ActionView::RecordIdentifier.dom_id(tickets(:export_failure))}"
    assert_select "tr.row-high, tr.row-urgent", 2
  end

  test "show marks unassigned tickets for an agent" do
    sign_in_as users(:agent)

    get root_path

    assert_select "##{ActionView::RecordIdentifier.dom_id(tickets(:slow_login))} .unassigned", "Unassigned"
    assert_select "##{ActionView::RecordIdentifier.dom_id(tickets(:export_failure))}", /agent@example\.com/
  end

  test "show does not give customers the agent filters" do
    sign_in_as users(:customer)

    get root_path

    assert_select "nav[aria-label=?]", "Filter by status", count: 0
    assert_select "tbody tr", 2
  end
end
