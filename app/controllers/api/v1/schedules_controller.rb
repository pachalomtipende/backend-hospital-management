module Api
  module V1
    class SchedulesController < ApplicationController
      skip_before_action :verify_authenticity_token, raise: false

      # GET /api/v1/schedules?date=YYYY-MM-DD
      def show
        date = params[:date].present? ? Date.parse(params[:date]) : Date.current
        
        appointments = Appointment.where("created_at >= ? AND created_at <= ?", date.beginning_of_day, date.end_of_day)
                                  .order(scheduled_at: :asc, priority_score: :desc)
                                  .includes(:patient, :consultation)

        grouped_schedule = {
          pending: appointments.select { |a| a.status == 'pending' },
          scheduled: appointments.select { |a| a.status == 'scheduled' },
          confirmed: appointments.select { |a| a.status == 'confirmed' },
          overridden: appointments.select { |a| a.status == 'overridden' },
          completed: appointments.select { |a| a.status == 'completed' },
          cancelled: appointments.select { |a| a.status == 'cancelled' }
        }

        render json: { date: date, schedule: grouped_schedule }, status: :ok
      rescue ArgumentError
        render json: { error: "Invalid date format" }, status: :bad_request
      end

      # POST /api/v1/schedules/generate
      def generate
        date = params[:date].present? ? Date.parse(params[:date]) : Date.current
        scheduled = SchedulingEngine.new(date: date).generate
        
        render json: { message: "Generated full schedule", scheduled_count: scheduled.count }, status: :ok
      end

      # POST /api/v1/schedules/incremental
      def incremental
        date = params[:date].present? ? Date.parse(params[:date]) : Date.current
        scheduled = SchedulingEngine.new(date: date).incremental
        
        render json: { message: "Incrementally rescheduled pending walk-ins", scheduled_count: scheduled.count }, status: :ok
      end
    end
  end
end
