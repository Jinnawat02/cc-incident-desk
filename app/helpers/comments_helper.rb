module CommentsHelper
  def comment_placeholder
    Current.user.agent? ? "Write a reply…" : "Write a comment…"
  end
end
