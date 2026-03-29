class Patient < ApplicationRecord
  has_secure_password  # this will add the password and password_confirmation fields automatically

  # Validations
  validates :first_name, :last_name, :email, :phone, :date_of_birth, presence: true
  validates :email, uniqueness: true
  validates :password, length: { minimum: 6 }, if: -> { new_record? || !password.nil? }

end
