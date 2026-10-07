class AddEscalatedAtToTickets < ActiveRecord::Migration[8.1]
  def change
    add_column :tickets, :escalated_at, :datetime
  end
end
