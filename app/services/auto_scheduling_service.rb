class AutoSchedulingService
  SLOT_DURATION = 30.minutes

  def call
    pending_appointments = Appointment.where(status: 'pending')
                                      .order(priority_score: :desc, created_at: :asc)

    return [] if pending_appointments.empty?

    current_time = Time.current
    # Next available slot is the latest scheduled time or the top of the next hour
    latest_time = Appointment.where(status: 'scheduled').maximum(:scheduled_at)
    
    start_time = if latest_time && latest_time > current_time
                   latest_time + SLOT_DURATION
                 else
                   current_time.beginning_of_hour + 1.hour
                 end

    scheduled_appointments = []

    Appointment.transaction do
      pending_appointments.each do |appointment|
        appointment.update!(
          status: 'scheduled',
          scheduled_at: start_time
        )
        scheduled_appointments << appointment
        start_time += SLOT_DURATION
      end
    end

    scheduled_appointments
  end
end
