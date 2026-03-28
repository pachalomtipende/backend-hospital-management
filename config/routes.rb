Rails.application.routes.draw do
  post "/api/create", to: "patients#send_confirmation_email"
  post "/api/verify", to: "patients#verify_email"

end
