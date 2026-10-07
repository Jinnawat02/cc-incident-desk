class CreateTickets < ActiveRecord::Migration[8.1]
  def change
    create_table :tickets do |t|
      t.string :title, null: false
      t.text :description, null: false
      t.integer :severity, null: false
      t.integer :status, null: false, default: 0
      t.references :creator, null: false, foreign_key: { to_table: :users }
      t.references :assignee, foreign_key: { to_table: :users }

      t.timestamps
    end
    add_index :tickets, :status
    add_index :tickets, :severity
  end
end
