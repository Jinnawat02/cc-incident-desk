class CommentBroadcaster
  include ActionView::RecordIdentifier

  def comment_posted(comment)
    ticket = comment.ticket

    Turbo::StreamsChannel.broadcast_append_later_to(ticket, target: dom_id(ticket, :comments), partial: "comments/comment", locals: { comment: comment })
    Turbo::StreamsChannel.broadcast_update_later_to(ticket, target: dom_id(ticket, :comments_count), html: ticket.comments.count.to_s)
  end
end
