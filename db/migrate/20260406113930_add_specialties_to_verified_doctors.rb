class AddSpecialtiesToVerifiedDoctors < ActiveRecord::Migration[8.1]
  def change
    add_column :verified_doctors, :specialties, :text
  end
end
