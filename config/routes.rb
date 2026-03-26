Rails.application.routes.draw do
  post "/api/create", to: "patients#create"

end
