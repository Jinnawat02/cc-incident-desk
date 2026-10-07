class PostComment
  attr_reader :comment

  def initialize(ticket, author:, notifier: CommentBroadcaster.new)
    @ticket = ticket
    @author = author
    @notifier = notifier
  end

  def call(attributes)
    @comment = @ticket.comments.build(attributes.merge(author: @author))
    return false unless @comment.save

    @notifier.comment_posted(@comment)
    true
  end
end
