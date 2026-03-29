class PatientsController < ApplicationController
  def send_confirmation_email
    email = params.require(:patient)[:email]
    confirmation_code = rand(100000..999999).to_s
    Rails.cache.write("signup:#{email}", {
      params: params.require(:patient)
                    .permit(:first_name, :last_name, :email, :phone, :date_of_birth, :password, :password_confirmation)
                    .to_h,
      code: confirmation_code
    }, expires_in: 15.minutes)

    PatientMailer.confirmation_email(email, confirmation_code).deliver_now

    render json: { message: "Check your email for the confirmation code" }
  end

  def verify_email
    email =  params.require(:patient)[:email]
    submitted_code = params.require(:patient)[:confirmation_code]

    cached = Rails.cache.read("signup:#{email}")

    if cached && cached[:code] == submitted_code
      patient = Patient.create!(cached[:params])
      Rails.cache.delete("signup:#{email}")
      render json: { message: "Account created successfully!", patient_id: patient.id }, status: :created
    else
      render json: { errors: ["Invalid or expired confirmation code"] }, status: :unprocessable_entity
    end
  end
  def log_in
    email = params.require(:patient)[:email]
    password = params.require(:patient)[:password]

    patient = Patient.find_by(email: email)

    if patient && patient.authenticate(password)
      render json: { message: "log in successful"}, status: :ok
    else
      render json: { error: "invalid email or password"}, status: :unauthorized

    end
  end

end