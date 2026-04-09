require "test_helper"

class Api::V1::AppointmentsControllerTest < ActionDispatch::IntegrationTest
  setup do
    Appointment.destroy_all
    Patient.destroy_all
    User.destroy_all
  end

  test "should create an appointment with prioritized symptoms" do
    post api_v1_appointments_url, params: { symptoms: ["chest pain"] }, as: :json
    
    assert_response :created
    json = JSON.parse(response.body)
    assert_equal "HIGH", json["appointment"]["priority_level"]
    assert_equal "pending", json["appointment"]["status"]
  end

  test "queue returns pending appointments sorted by priority" do
    u = User.create!(email: "test1@example.com", password: "password", role: :patient)
    p = Patient.create!(user: u, name: "Test", phone: "123")
    Appointment.create!(patient: p, status: "pending", priority_score: 10, priority_level: "LOW", symptoms: [])
    Appointment.create!(patient: p, status: "pending", priority_score: 90, priority_level: "HIGH", symptoms: [])

    get queue_api_v1_appointments_url, as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 2, json.length
    assert_equal 90, json.first["priority_score"]
  end

  test "auto_schedule triggers scheduling service" do
    u = User.create!(email: "test2@example.com", password: "password", role: :patient)
    p = Patient.create!(user: u, name: "Test", phone: "123")
    Appointment.create!(patient: p, status: "pending", priority_score: 90, priority_level: "HIGH", symptoms: [])

    post auto_schedule_api_v1_appointments_url, as: :json
    assert_response :success
    json = JSON.parse(response.body)
    assert_equal 1, json["appointments"].length
    assert_equal "scheduled", json["appointments"].first["status"]
  end
end
