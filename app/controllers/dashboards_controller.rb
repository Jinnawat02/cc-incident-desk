class DashboardsController < ApplicationController
  def show
    @filter = TicketStatusFilter.new(Current.user.visible_tickets, params[:status])
    @tickets = @filter.tickets.includes(:creator, :assignee).recent_first
  end
end
