class CreateConsultations < ActiveRecord::Migration[8.1]
  def change
    create_table :consultations do |t|
      t.integer :appointment_id, null: false
      t.string  :doctor_name,   null: false
      t.text    :diagnosis,     null: false
      t.text    :treatment
      t.text    :notes
      t.datetime :consulted_at

      t.timestamps
    end

    add_index :consultations, :appointment_id
    add_foreign_key :consultations, :appointments
  end
end
