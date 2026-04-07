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
        severity = params[:severity] || 'low'
        
        if symptoms.blank? || !(symptoms.is_a?(Array) || symptoms.is_a?(String))
          return render json: { error: "Please provide symptoms as an array or a description string" }, status: :bad_request
        end
        
        # The AI Service processes keyword arrays and full sentences
        ai_result = AiPrioritizationService.new(symptoms, severity: severity).call
        
        appointment = Appointment.new(
          patient_id: patient_id,
          symptoms: ai_result[:detected_symptoms],
          priority_level: ai_result[:priority_level],
          priority_score: ai_result[:priority_score],
          severity: ai_result[:severity_input],
          status: 'pending'
        )

        if appointment.save
          render json: {
            appointment: appointment,
            first_aid_advice: ai_result[:first_aid_advice]
          }, status: :created
        else
          render json: { error: appointment.errors.full_messages.join(', ') }, status: :unprocessable_entity
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

      # DELETE /api/v1/appointments/:id
      def destroy
        appointment = Appointment.find(params[:id])
        appointment.destroy
        head :no_content
      end

      # DELETE /api/v1/appointments/clear_all
      def clear_all
        Appointment.where(status: 'pending').destroy_all
        head :no_content
      end
    end
  end
end
