require "test_helper"

class PostCommentTest < ActiveSupport::TestCase
  class RecordingNotifier
    attr_reader :comments

    def initialize
      @comments = []
    end

    def comment_posted(comment)
      @comments << comment
    end
  end

  setup do
    @ticket = tickets(:slow_login)
    @notifier = RecordingNotifier.new
    @posting = PostComment.new(@ticket, author: users(:customer), notifier: @notifier)
  end

  test "saves the comment for the author and notifies" do
    assert_difference -> { @ticket.comments.count }, 1 do
      assert @posting.call(body: "Still slow today.")
    end

    assert_equal users(:customer), @posting.comment.author
    assert_equal [ @posting.comment ], @notifier.comments
  end

  test "does not save or notify for a blank body" do
    assert_no_difference -> { Comment.count } do
      assert_not @posting.call(body: "")
    end

    assert_empty @notifier.comments
  end

  test "ignores an author supplied in the attributes" do
    @posting.call(body: "Hello", author: users(:agent))

    assert_equal users(:customer), @posting.comment.author
  end
end
