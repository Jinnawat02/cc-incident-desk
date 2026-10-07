class CommentsController < ApplicationController
  before_action :set_ticket

  def create
    @posting = PostComment.new(@ticket, author: Current.user)

    if @posting.call(comment_params)
      respond_to do |format|
        format.turbo_stream
        format.html { redirect_to @ticket }
      end
    else
      respond_to do |format|
        format.turbo_stream { render :form, status: :unprocessable_entity }
        format.html { redirect_to @ticket, alert: @posting.comment.errors.full_messages.to_sentence }
      end
    end
  end

  private
    def set_ticket
      @ticket = Current.user.visible_tickets.find(params[:ticket_id])
    end

    def comment_params
      params.expect(comment: [ :body ])
    end
end
