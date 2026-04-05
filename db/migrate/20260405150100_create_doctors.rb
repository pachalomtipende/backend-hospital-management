class CreateDoctors < ActiveRecord::Migration[8.1]
  def change
    create_table :doctors do |t|
      t.string :full_name
      t.string :professional_title
      t.string :clinic
      t.string :medical_license_number
      t.string :email
      t.string :phone_number
      t.string :password_digest
      t.json :specialties

      t.timestamps
    end
  end
end
