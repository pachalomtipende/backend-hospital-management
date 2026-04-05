class Doctor < ApplicationRecord
  has_secure_password

  # File upload
  has_one_attached :document

  # Basic validations
  validates :full_name, :professional_title, :clinic,
            :medical_license_number, :email,
            :phone_number, presence: true

  validates :email, uniqueness: true

  # Simple specialties validation (Option 3)
  validates :specialties, presence: true

  # File validation (optional but recommended)
  validate :document_type

  private

  def document_type
    return unless document.attached?

    unless document.content_type.in?(%w[image/png image/jpeg application/pdf])
      errors.add(:document, "must be PNG, JPG, or PDF")
    end
  end
end