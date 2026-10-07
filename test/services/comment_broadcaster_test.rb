require "test_helper"

class CommentBroadcasterTest < ActiveSupport::TestCase
  include ActiveJob::TestHelper
  include ActionView::RecordIdentifier

  test "appends the comment and refreshes the count on the ticket stream" do
    comment = comments(:agent_reply)

    perform_enqueued_jobs do
      CommentBroadcaster.new.comment_posted(comment)
    end

    append, count = capture_turbo_stream_broadcasts(comment.ticket)
    assert_equal [ "append", dom_id(comment.ticket, :comments) ], [ append["action"], append["target"] ]
    assert_includes append.to_html, comment.body
    assert_equal [ "update", dom_id(comment.ticket, :comments_count) ], [ count["action"], count["target"] ]
    assert_includes count.to_html, "2"
  end
end
