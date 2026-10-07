class DashboardsController < ApplicationController
  def show
    @tickets = Current.user.visible_tickets.recent_first
  end
end
