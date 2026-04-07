class DoctorsController < ApplicationController
  def doctor_login
    email = params.require(:doctor)[:email]
    password = params.require(:doctor)[:password]
    clinic = params.require(:doctor)[:clinic]

    doctor = VerifiedDoctor.find_by(email: email)

    if doctor && doctor.authenticate(password) && doctor.clinic == clinic
      render json: { message: "Login successful" }
    else
      render json: { errors: "login unsuccessful" }, status: :unprocessable_entity
    end
  end

  def index
    doctors = Doctor.all
    render json: doctors.map { |doctor|
      {
        id: doctor.id,
        full_name: doctor.full_name,
        email: doctor.email,
        document_url: doctor.document.attached? ? url_for(doctor.document) : nil
      }
    }
  end



  def verify
    doctor = Doctor.find(params[:id])

    if doctor.full_name.present? && doctor.email.present?
      # Create verified doctor
      verified_doctor = VerifiedDoctor.new(
        full_name: doctor.full_name,
        professional_title: doctor.professional_title,
        clinic: doctor.clinic,
        medical_license_number: doctor.medical_license_number,
        email: doctor.email,
        phone_number: doctor.phone_number,
        password_digest: doctor.password_digest,
        specialties: doctor.specialties
      )

      if verified_doctor.save

        verified_doctor.document.attach(doctor.document.blob) if doctor.document.attached?


        DoctorMailer.verified_email(doctor).deliver_now


        doctor.destroy

        render json: { message: "Doctor verified and saved successfully" }
      else
        render json: { errors: verified_doctor.errors.full_messages }, status: :unprocessable_entity
      end
    else

      DoctorMailer.not_verified_email(doctor).deliver_later
      render json: { message: "Doctor credentials not valid" }, status: :unprocessable_entity
    end
  end

  def reject
    doctor = Doctor.find(params[:id])
    DoctorMailer.not_verified_email(doctor).deliver_now
    doctor.destroy
    render json: { message: "Doctor application rejected" }
  end

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



  private


  def valid_credentials?(doctor)
    doctor.full_name.present? && doctor.email.present? && doctor.document.attached?
  end

end