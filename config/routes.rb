Rails.application.routes.draw do
  post "/api/create", to: "patients#send_confirmation_email"
  post "/api/verify", to: "patients#verify_email"
  post "/api/login", to: "patients#log_in"
  post "/api/doctor", to: "doctors#create"

end
