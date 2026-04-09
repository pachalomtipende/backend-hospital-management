class Appointment < ApplicationRecord
  belongs_to :patient
  has_one :consultation, dependent: :destroy
  serialize :symptoms, coder: JSON

  validates :status, inclusion: { in: %w[pending scheduled confirmed overridden cancelled completed] }
end
