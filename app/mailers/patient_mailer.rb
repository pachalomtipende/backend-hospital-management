class PatientMailer < ApplicationMailer


  def confirmation_email(to_email, confirmation_code)
    @confirmation_code = confirmation_code

    mail(
      to: to_email,                  # <-- this is critical
      from: "pmtipende@gmail.com",   # your sender email
      subject: "Confirm your CareConnect email")
  end


end
