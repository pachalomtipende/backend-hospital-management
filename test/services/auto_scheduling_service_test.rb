require "test_helper"

class AutoSchedulingServiceTest < ActiveSupport::TestCase
  setup do
    Patient.destroy_all
    Appointment.destroy_all
    @patient = Patient.create!(name: "Test", email: "test@example.com", phone: "123")
  end

  test "schedules pending appointments in order of priority" do
    Appointment.create!(patient: @patient, priority_level: "LOW", priority_score: 10, status: "pending", symptoms: ["headache"])
    Appointment.create!(patient: @patient, priority_level: "HIGH", priority_score: 90, status: "pending", symptoms: ["chest pain"])
    Appointment.create!(patient: @patient, priority_level: "MEDIUM", priority_score: 50, status: "pending", symptoms: ["fever"])

    scheduled = AutoSchedulingService.new.call

    assert_equal 3, scheduled.count
    # Should be scheduled in HIGH, MEDIUM, LOW order
    assert_equal 90, scheduled[0].priority_score
    assert_equal 50, scheduled[1].priority_score
    assert_equal 10, scheduled[2].priority_score

    assert_equal "scheduled", scheduled[0].status
    assert_not_nil scheduled[0].scheduled_at

    # Check times are sequential
    assert scheduled[1].scheduled_at > scheduled[0].scheduled_at
    assert scheduled[2].scheduled_at > scheduled[1].scheduled_at
  end

  test "returns empty array when no pending appointments" do
    assert_equal [], AutoSchedulingService.new.call
  end
end
