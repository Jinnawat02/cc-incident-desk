class TicketStatusFilter
  ALL = "all"

  attr_reader :selected

  def initialize(scope, status)
    @scope = scope
    @selected = Ticket.statuses.key?(status) ? status : ALL
  end

  def tickets
    all_selected? ? @scope : @scope.where(status: selected)
  end

  def options
    [ ALL, *Ticket.statuses.keys ]
  end

  def selected?(option)
    option == selected
  end

  def count_for(option)
    option == ALL ? counts_by_status.values.sum : counts_by_status.fetch(option, 0)
  end

  private
    def all_selected?
      selected == ALL
    end

    def counts_by_status
      @counts_by_status ||= @scope.group(:status).count
    end
end
