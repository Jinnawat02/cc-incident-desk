# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_07_120000) do
  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "ticket_status_changes", force: :cascade do |t|
    t.integer "ticket_id", null: false
    t.integer "actor_id", null: false
    t.integer "from_status", null: false
    t.integer "to_status", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_id"], name: "index_ticket_status_changes_on_actor_id"
    t.index ["ticket_id"], name: "index_ticket_status_changes_on_ticket_id"
  end

  create_table "tickets", force: :cascade do |t|
    t.string "title", null: false
    t.text "description", null: false
    t.integer "severity", null: false
    t.integer "status", default: 0, null: false
    t.integer "creator_id", null: false
    t.integer "assignee_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["assignee_id"], name: "index_tickets_on_assignee_id"
    t.index ["creator_id"], name: "index_tickets_on_creator_id"
    t.index ["severity"], name: "index_tickets_on_severity"
    t.index ["status"], name: "index_tickets_on_status"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.integer "role", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
  end

  add_foreign_key "sessions", "users"
  add_foreign_key "ticket_status_changes", "tickets"
  add_foreign_key "ticket_status_changes", "users", column: "actor_id"
  add_foreign_key "tickets", "users", column: "assignee_id"
  add_foreign_key "tickets", "users", column: "creator_id"
end
