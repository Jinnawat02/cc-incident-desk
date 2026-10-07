class CreateTicketStatusChanges < ActiveRecord::Migration[8.1]
  def change
    create_table :ticket_status_changes do |t|
      t.references :ticket, null: false, foreign_key: true
      t.references :actor, null: false, foreign_key: { to_table: :users }
      t.integer :from_status, null: false
      t.integer :to_status, null: false

      t.timestamps
    end
  end
end
