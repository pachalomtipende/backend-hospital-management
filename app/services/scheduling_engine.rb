class SchedulingEngine
  SLOT_DURATION = 30.minutes

  # Initialize with a specific date
  def initialize(date: Date.current)
    @date = date.to_date
    @start_of_day = @date.beginning_of_day + 8.hours # Starts at 08:00 AM
  end

  # generate: Completely resets the schedule for unconfirmed appointments
  # Only pending and scheduled appointments are affected. 
  # If there are confirmed appointments, it will NOT touch them, but for a 
  # completely clean state, usually generate is run early in the day.
  def generate
    # Find all appointments for the day that haven't been completed/cancelled
    appointments = Appointment.where("created_at >= ? AND created_at <= ?", @date.beginning_of_day, @date.end_of_day)
                              .where(status: ['pending', 'scheduled'])
                              .order(priority_score: :desc, created_at: :asc)

    return [] if appointments.empty?

    current_slot = @start_of_day
    scheduled_appointments = []

    Appointment.transaction do
      appointments.each do |appointment|
        # Fast-forward past any confirmed or overridden slots that might occupy this time
        current_slot = next_available_slot(current_slot)

        appointment.update!(
          status: 'scheduled',
          scheduled_at: current_slot
        )
        scheduled_appointments << appointment
        
        current_slot += SLOT_DURATION
      end
    end

    scheduled_appointments
  end

  # incremental: Only affects the un-slotted (pending) appointments or re-shuffles the scheduled ones 
  # without touching the currently confirmed or overridden ones.
  def incremental
    pending_or_scheduled = Appointment.where("created_at >= ? AND created_at <= ?", @date.beginning_of_day, @date.end_of_day)
                                      .where(status: ['pending', 'scheduled'])
                                      .order(priority_score: :desc, created_at: :asc)

    return [] if pending_or_scheduled.empty?

    # Define the starting point as the beginning of the day, or current time, or whichever is later?
    # Because it is incremental, we start at 08:00 AM, but skip over any slots already locked by confirmed appointments.
    current_slot = @start_of_day
    
    # We might want to not schedule in the past.
    if @date == Date.current && Time.current > @start_of_day
      # Current time rounded to next slot
      current_slot = Time.current.change(sec: 0, min: (Time.current.min / 30.0).ceil * 30)
      # ensure it's not starting at exactly top of hour if the minutes were zero and we ceiled to next 30 min boundary. 
      # Actually `change(min: ...)` will just work or shift up. Let's use a simpler approach.
      current_slot = Time.at((Time.current.to_f / SLOT_DURATION).ceil * SLOT_DURATION)
    end

    scheduled_appointments = []

    Appointment.transaction do
      pending_or_scheduled.each do |appointment|
        current_slot = next_available_slot(current_slot)

        appointment.update!(
          status: 'scheduled',
          scheduled_at: current_slot
        )
        scheduled_appointments << appointment
        
        current_slot += SLOT_DURATION
      end
    end

    scheduled_appointments
  end

  private

  # Finds the next 30-min slot that is NOT occupied by a confirmed or completed or overridden appointment
  def next_available_slot(requested_slot)
    slot = requested_slot
    # Get all locked appointments for today
    locked_appointments = Appointment.where("created_at >= ? AND created_at <= ?", @date.beginning_of_day, @date.end_of_day)
                                     .where(status: ['confirmed', 'overridden', 'completed'])
                                     .pluck(:scheduled_at).compact

    # While the slot is taken, move to the next 30 min max 100 times to avoid infinite loop
    100.times do
      break unless locked_appointments.include?(slot)
      slot += SLOT_DURATION
    end

    slot
  end
end
