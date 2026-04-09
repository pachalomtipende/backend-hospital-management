class User < ApplicationRecord
  has_secure_password
  enum :role, { patient: 0, doctor: 1, receptionist: 2, admin: 3 }
  has_one :patient, dependent: :destroy
end
