class Appointment < ApplicationRecord
  belongs_to :patient
  serialize :symptoms, coder: JSON
end
