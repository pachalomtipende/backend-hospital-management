class DoctorsController < ApplicationController
  def create
    doctor = Doctor.new(doctor_params)

    if doctor.save
      render json: { message: "Doctor registered successfully" }, status: :created
    else
      render json: { errors: doctor.errors.full_messages }, status: :unprocessable_entity
    end
  end

  private

  def doctor_params
    params.require(:doctor).permit(
      :full_name,
      :professional_title,
      :clinic,
      :medical_license_number,
      :email,
      :phone_number,
      :password,
      :password_confirmation,
      :document,
      specialties: []
    )
  end
end