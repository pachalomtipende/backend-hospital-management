class Consultation < ApplicationRecord
  belongs_to :appointment

  validates :doctor_name, presence: true
  validates :diagnosis, presence: true
end
