module Api
  module V1
    class UsersController < ApplicationController
      before_action :authorize_request, except: :create

      def index
        # Only admin should see all users, but we'll add basic check later
        @users = User.all
        render json: @users, status: :ok
      end

      def create
        @user = User.new(user_params)
        if @user.save
          if @user.patient?
            @user.create_patient!(patient_params)
          end
          token = JsonWebToken.encode(user_id: @user.id)
          render json: { token: token, user: @user }, status: :created
        else
          render json: { errors: @user.errors.full_messages },
                 status: :unprocessable_entity
        end
      end

      private

      def user_params
        params.permit(:email, :password, :password_confirmation, :role)
      end

      def patient_params
        params.permit(:name, :phone, :date_of_birth)
      end
    end
  end
end
