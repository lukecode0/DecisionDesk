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

ActiveRecord::Schema[8.1].define(version: 2026_03_19_193000) do
  create_table "submissions", force: :cascade do |t|
    t.string "annual_revenue"
    t.string "applicant_email", null: false
    t.string "applicant_name", null: false
    t.string "county"
    t.datetime "created_at", null: false
    t.text "decision_path_json", default: "[]", null: false
    t.string "entity_type", null: false
    t.string "household_income"
    t.string "np_years_active"
    t.string "outcome", null: false
    t.text "reason", null: false
    t.string "serves_youth"
    t.string "status", null: false
    t.datetime "updated_at", null: false
    t.string "urgent_need"
    t.string "veteran"
    t.string "years_active"
    t.index ["created_at"], name: "index_submissions_on_created_at"
    t.index ["entity_type"], name: "index_submissions_on_entity_type"
    t.index ["outcome"], name: "index_submissions_on_outcome"
    t.index ["status"], name: "index_submissions_on_status"
  end
end
