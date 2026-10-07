class TicketsController < ApplicationController
  before_action :require_customer, only: %i[ new create ]
  before_action :set_ticket, only: :show

  def new
    @ticket = Ticket.new(severity: :medium)
  end

  def create
    @ticket = Current.user.created_tickets.build(ticket_params)

    if @ticket.save
      redirect_to @ticket
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
  end

  private
    def set_ticket
      @ticket = Current.user.visible_tickets.find(params[:id])
    end

    def ticket_params
      params.expect(ticket: %i[ title description severity ])
    end
end
