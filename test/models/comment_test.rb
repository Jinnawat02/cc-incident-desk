require "test_helper"

class CommentTest < ActiveSupport::TestCase
  test "is valid with a body, ticket and author" do
    comment = Comment.new(ticket: tickets(:slow_login), author: users(:customer), body: "Any update?")

    assert comment.valid?
  end

  test "requires a body" do
    comment = Comment.new(ticket: tickets(:slow_login), author: users(:customer), body: " ")

    assert_not comment.valid?
    assert_includes comment.errors[:body], "can't be blank"
  end

  test "limits the body length" do
    comment = Comment.new(ticket: tickets(:slow_login), author: users(:customer), body: "a" * 10_001)

    assert_not comment.valid?
  end

  test "chronological lists the oldest comment first" do
    assert_equal [ comments(:customer_report), comments(:agent_reply) ], tickets(:export_failure).comments.chronological.to_a
  end
end
