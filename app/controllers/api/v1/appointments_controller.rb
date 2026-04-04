module Api
  module V1
    class AppointmentsController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false

      # POST /api/v1/appointments
      def create
        # For demonstration purposes: Ensure a guest user exists
        guest_user = User.find_or_create_by!(email: "guest@example.com") do |u|
          u.password = "password"
          u.role = :patient
        end

        # Ensure a guest patient exists for that user
        patient = Patient.find_or_create_by!(user_id: guest_user.id) do |p|
          p.name = "Guest Patient"
          p.phone = "000-000-0000"
        end

        patient_id = params[:patient_id] || patient.id
        
        symptoms = params[:symptoms]
        
        if symptoms.blank? || !symptoms.is_a?(Array)
          return render json: { error: "Please provide an array of symptoms" }, status: :bad_request
        end
        
        ai_result = AiPrioritizationService.new(symptoms).call
        
        appointment = Appointment.new(
          patient_id: patient_id,
          symptoms: symptoms,
          priority_level: ai_result[:priority_level],
          priority_score: ai_result[:priority_score],
          status: 'pending'
        )

        if appointment.save
          render json: appointment, status: :created
        else
          render json: { errors: appointment.errors.full_messages }, status: :unprocessable_entity
        end
      end

      # GET /api/v1/appointments/queue
      def queue
        pending_appointments = Appointment.where(status: 'pending')
                                          .order(priority_score: :desc, created_at: :asc)
                                          .includes(:patient)
        
        render json: pending_appointments.as_json(include: :patient), status: :ok
      end

      # POST /api/v1/appointments/auto_schedule
      def auto_schedule
        scheduled = AutoSchedulingService.new.call
        
        render json: { 
          message: "Successfully scheduled #{scheduled.count} appointments",
          appointments: scheduled
        }, status: :ok
      end
    end
  end
end
