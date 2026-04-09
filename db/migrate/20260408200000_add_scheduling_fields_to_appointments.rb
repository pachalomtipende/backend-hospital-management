class AddSchedulingFieldsToAppointments < ActiveRecord::Migration[8.1]
  def change
    add_column :appointments, :confirmed_by, :string
    add_column :appointments, :override_reason, :text
    add_column :appointments, :overridden_at, :datetime
  end
end
