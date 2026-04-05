class DoctorMailer < ApplicationMailer
  def verified_email(doctor)
    @doctor = doctor
    mail(to: @doctor.email, from: "pmtipende@gmail.com", subject: "Your credentials have been verified ✅")
  end

  def not_verified_email(doctor)
    @doctor = doctor
    mail(to: @doctor.email, from: "pmtipende@gmail.com", subject: "Credentials not valid ❌")
  end
end
