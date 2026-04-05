class VerifiedDoctor < ApplicationRecord

    has_secure_password
    has_one_attached :document

    validates :specialties, presence: true

    validates :full_name, :email, presence: true
  end

