require "test_helper"

class CommentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @ticket = tickets(:slow_login)
    @customer = users(:customer)
  end

  test "create lets a customer comment on their own ticket and clears the form" do
    sign_in_as @customer

    assert_difference -> { @ticket.comments.count }, 1 do
      post ticket_comments_path(@ticket), params: { comment: { body: "Still slow this morning." } }, as: :turbo_stream
    end

    assert_response :success
    assert_equal users(:customer), @ticket.comments.last.author
    assert_select "turbo-stream[action=append][target=?]", "comments_ticket_#{@ticket.id}", /Still slow this morning\./
    assert_select "turbo-stream[action=update][target=?]", "comments_count_ticket_#{@ticket.id}"
    assert_select "turbo-stream[action=replace][target=?]", "comment_form_ticket_#{@ticket.id}" do
      assert_select "template textarea", text: ""
    end
  end

  test "create lets an agent comment on any ticket" do
    sign_in_as users(:agent)
    ticket = tickets(:invoice_typo)

    assert_difference -> { ticket.comments.count }, 1 do
      post ticket_comments_path(ticket), params: { comment: { body: "Fixed in the next release." } }, as: :turbo_stream
    end

    assert_response :success
  end

  test "create broadcasts the new comment to everyone watching the ticket" do
    sign_in_as @customer

    perform_enqueued_jobs do
      post ticket_comments_path(@ticket), params: { comment: { body: "Any news?" } }, as: :turbo_stream
    end

    assert_turbo_stream_broadcasts @ticket, count: 2
  end

  test "create with a blank body re-renders the form with an error" do
    sign_in_as @customer

    assert_no_difference -> { Comment.count } do
      post ticket_comments_path(@ticket), params: { comment: { body: "" } }, as: :turbo_stream
    end

    assert_response :unprocessable_entity
    assert_select "turbo-stream[action=replace][target=?]", "comment_form_ticket_#{@ticket.id}" do
      assert_select "template [role=alert]", "Body can't be blank"
    end
  end

  test "create without turbo redirects back to the ticket" do
    sign_in_as @customer

    post ticket_comments_path(@ticket), params: { comment: { body: "Plain form post." } }

    assert_redirected_to ticket_path(@ticket)
    assert_equal "Plain form post.", @ticket.comments.last.body
  end

  test "create without turbo and a blank body redirects with an alert" do
    sign_in_as @customer

    post ticket_comments_path(@ticket), params: { comment: { body: "" } }

    assert_redirected_to ticket_path(@ticket)
    assert_equal "Body can't be blank", flash[:alert]
  end

  test "create on another customer's ticket is not found" do
    sign_in_as @customer

    assert_no_difference -> { Comment.count } do
      post ticket_comments_path(tickets(:invoice_typo)), params: { comment: { body: "Sneaky." } }, as: :turbo_stream
    end

    assert_response :not_found
  end

  test "create requires authentication" do
    assert_no_difference -> { Comment.count } do
      post ticket_comments_path(@ticket), params: { comment: { body: "Hello?" } }
    end

    assert_redirected_to new_session_path
  end
end
