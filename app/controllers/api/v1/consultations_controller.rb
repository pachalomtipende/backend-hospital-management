module Api
  module V1
    class ConsultationsController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false

      # POST /api/v1/appointments/:appointment_id/consultations
      def create
        appointment = Appointment.find(params[:appointment_id])
        
        if %w[completed cancelled].include?(appointment.status)
          return render json: { error: "Appointment is already #{appointment.status}" }, status: :unprocessable_entity
        end

        consultation = appointment.build_consultation(
          doctor_name: params[:doctor_name] || (@current_user&.role == 'doctor' ? @current_user.email : 'Unknown Doctor'),
          diagnosis: params[:diagnosis],
          treatment: params[:treatment],
          notes: params[:notes],
          consulted_at: Time.current
        )

        Appointment.transaction do
          if consultation.save
            appointment.update!(status: 'completed')
            render json: consultation, status: :created
          else
            render json: { error: consultation.errors.full_messages }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
