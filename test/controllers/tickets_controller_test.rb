require "test_helper"

class TicketsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @customer = users(:customer)
    @valid_params = { ticket: { title: "Dashboard is blank", description: "The dashboard shows nothing after login.", severity: "urgent" } }
  end

  test "new renders the ticket form for a customer" do
    sign_in_as @customer

    get new_ticket_path

    assert_response :success
    assert_select "form[action=?]", tickets_path do
      assert_select "input[name=?]", "ticket[title]"
      assert_select "textarea[name=?]", "ticket[description]"
      assert_select "select[name=?] option", "ticket[severity]", count: 4
      assert_select "select[name=?] option[selected]", "ticket[severity]", text: "Medium"
    end
  end

  test "new redirects an agent away" do
    sign_in_as users(:agent)

    get new_ticket_path

    assert_redirected_to root_path
    assert_equal "Only customers can do that.", flash[:alert]
  end

  test "new requires authentication" do
    get new_ticket_path

    assert_redirected_to new_session_path
  end

  test "create opens a ticket for the customer and shows it" do
    sign_in_as @customer

    assert_difference -> { @customer.created_tickets.count }, 1 do
      post tickets_path, params: @valid_params
    end

    ticket = @customer.created_tickets.recent_first.first
    assert_redirected_to ticket_path(ticket)
    assert ticket.open?
    assert ticket.urgent?
    assert_nil ticket.assignee
  end

  test "create ignores attempts to set the status or creator" do
    sign_in_as @customer

    post tickets_path, params: { ticket: @valid_params[:ticket].merge(status: "resolved", creator_id: users(:other_customer).id) }

    ticket = Ticket.recent_first.first
    assert ticket.open?
    assert_equal @customer, ticket.creator
  end

  test "create with a short title and description re-renders the form" do
    sign_in_as @customer

    assert_no_difference -> { Ticket.count } do
      post tickets_path, params: { ticket: { title: "Bug", description: "Broken", severity: "low" } }
    end

    assert_response :unprocessable_entity
    assert_select "[role=alert]", /Title is too short \(minimum is 5 characters\)/
    assert_select "[role=alert]", /Description is too short \(minimum is 10 characters\)/
  end

  test "create with an unknown severity re-renders the form" do
    sign_in_as @customer

    assert_no_difference -> { Ticket.count } do
      post tickets_path, params: { ticket: @valid_params[:ticket].merge(severity: "catastrophic") }
    end

    assert_response :unprocessable_entity
    assert_select "[role=alert]", /Severity is not included in the list/
  end

  test "create without ticket params is a bad request" do
    sign_in_as @customer

    post tickets_path, params: {}

    assert_response :bad_request
  end

  test "create is not allowed for an agent" do
    sign_in_as users(:agent)

    assert_no_difference -> { Ticket.count } do
      post tickets_path, params: @valid_params
    end

    assert_redirected_to root_path
  end

  test "create requires authentication" do
    assert_no_difference -> { Ticket.count } do
      post tickets_path, params: @valid_params
    end

    assert_redirected_to new_session_path
  end

  test "show renders the customer's own ticket" do
    sign_in_as @customer
    ticket = tickets(:slow_login)

    get ticket_path(ticket)

    assert_response :success
    assert_select "h1", ticket.title
    assert_select ".st", "Open"
    assert_select ".sev", "Medium"
    assert_select "aside", /Unassigned/
  end

  test "show hides another customer's ticket" do
    sign_in_as @customer

    get ticket_path(tickets(:invoice_typo))

    assert_response :not_found
  end

  test "show renders any ticket for an agent" do
    sign_in_as users(:agent)

    get ticket_path(tickets(:invoice_typo))

    assert_response :success
    assert_select "h1", tickets(:invoice_typo).title
  end

  test "show requires authentication" do
    get ticket_path(tickets(:slow_login))

    assert_redirected_to new_session_path
  end
end
