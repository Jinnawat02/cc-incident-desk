class TicketsController < ApplicationController
  before_action :require_customer, only: %i[ new create ]
  before_action :require_agent, only: :update
  before_action :set_ticket, only: %i[ show update ]

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

  def update
    if TicketUpdate.new(@ticket, actor: Current.user).call(ticket_update_params)
      redirect_to @ticket, notice: "Saved. The customer sees the new status now."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private
    def set_ticket
      @ticket = Current.user.visible_tickets.find(params[:id])
    end

    def ticket_params
      params.expect(ticket: %i[ title description severity ])
    end

    def ticket_update_params
      params.expect(ticket: %i[ status assignee_id ])
    end
end
