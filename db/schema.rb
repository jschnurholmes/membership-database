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

ActiveRecord::Schema[7.2].define(version: 2026_10_09_020000) do
  create_table "address_types", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.boolean "primary?"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "addresses", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "line_1"
    t.string "line_2"
    t.string "city"
    t.string "zip_code"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "membership_id"
    t.integer "state_id"
    t.integer "address_type_id"
    t.datetime "discarded_at", precision: nil
  end

  create_table "email_addresses", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "person_id"
    t.integer "type_id"
    t.string "email"
    t.boolean "primary?"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "email_types", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "mailing_preferences", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "membership_periods", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.date "effective_date"
    t.date "expiration_date"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "membership_records", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "membership_id"
    t.integer "membership_period_id"
    t.text "members"
    t.index ["membership_id", "membership_period_id"], name: "m_mp_mid_mpid"
    t.index ["membership_id"], name: "index_memberships_membership_periods_on_membership_id"
  end

  create_table "membership_types", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.decimal "cost", precision: 15, scale: 2
    t.datetime "discarded_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["discarded_at"], name: "index_membership_types_on_discarded_at"
  end

  create_table "memberships", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "membership_type_id"
    t.datetime "discarded_at", precision: nil
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.integer "membership_period_id"
    t.string "token"
    t.integer "mailing_preference_id"
    t.datetime "renewal_date", precision: nil
    t.index ["discarded_at"], name: "index_memberships_on_discarded_at"
    t.index ["token"], name: "index_memberships_on_token"
  end

  create_table "memberships_people", id: false, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "membership_id", null: false
    t.integer "person_id", null: false
    t.index ["membership_id"], name: "index_memberships_people_on_membership_id"
    t.index ["person_id"], name: "index_memberships_people_on_person_id"
  end

  create_table "people", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "first_name"
    t.string "middle_name"
    t.string "last_name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.datetime "discarded_at", precision: nil
    t.string "token"
    t.integer "latest_card_number", default: 0, null: false
    t.string "preferred_name"
    t.index ["discarded_at"], name: "index_people_on_discarded_at"
    t.index ["token"], name: "index_people_on_token"
  end

  create_table "people_tags", id: false, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.bigint "person_id"
    t.bigint "tag_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["person_id", "tag_id"], name: "index_people_tags_on_person_id_and_tag_id"
    t.index ["person_id"], name: "index_people_tags_on_person_id"
    t.index ["tag_id"], name: "index_people_tags_on_tag_id"
  end

  create_table "phone_numbers", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.integer "person_id"
    t.integer "type_id"
    t.string "phone_number"
    t.boolean "primary?"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "phone_types", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "states", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.string "abbreviation"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
  end

  create_table "tags", charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "color"
    t.integer "priority"
  end

  create_table "users", id: :integer, charset: "utf8mb4", collation: "utf8mb4_general_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at", precision: nil
    t.datetime "remember_created_at", precision: nil
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", precision: nil
    t.datetime "updated_at", precision: nil
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end
end
