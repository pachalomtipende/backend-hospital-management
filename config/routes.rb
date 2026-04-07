Rails.application.routes.draw do
  post "/api/create", to: "patients#send_confirmation_email"
  post "/api/verify", to: "patients#verify_email"
  post "/api/login", to: "patients#log_in"
  post "/api/doctor", to: "doctors#create"
  get "doctors", to: "doctors#index"
  post "doctors/:id/verify", to: "doctors#verify"
  post "doctors/:id/reject", to: "doctors#reject"
  post "api/doc_login", to: "doctors#doctor_login"


end
