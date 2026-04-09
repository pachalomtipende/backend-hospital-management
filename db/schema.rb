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

ActiveRecord::Schema[8.1].define(version: 2026_04_08_200001) do
  create_table "appointments", force: :cascade do |t|
    t.string "confirmed_by"
    t.datetime "created_at", null: false
    t.datetime "overridden_at"
    t.text "override_reason"
    t.integer "patient_id", null: false
    t.string "priority_level"
    t.integer "priority_score"
    t.datetime "scheduled_at"
    t.string "severity"
    t.string "status"
    t.text "symptoms"
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_appointments_on_patient_id"
  end

  create_table "consultations", force: :cascade do |t|
    t.integer "appointment_id", null: false
    t.datetime "consulted_at"
    t.datetime "created_at", null: false
    t.text "diagnosis", null: false
    t.string "doctor_name", null: false
    t.text "notes"
    t.text "treatment"
    t.datetime "updated_at", null: false
    t.index ["appointment_id"], name: "index_consultations_on_appointment_id"
  end

  create_table "patients", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.date "date_of_birth"
    t.string "name"
    t.string "phone"
    t.datetime "updated_at", null: false
    t.integer "user_id", null: false
    t.index ["user_id"], name: "index_patients_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "email"
    t.string "password_digest"
    t.integer "role"
    t.datetime "updated_at", null: false
  end

  add_foreign_key "appointments", "patients"
  add_foreign_key "consultations", "appointments"
  add_foreign_key "patients", "users"
end
