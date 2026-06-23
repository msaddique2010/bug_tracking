module Api
  module V1
    class ApiController < ActionController::API
      include Pundit::Authorization

      before_action :authenticate_user!

      rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
      rescue_from ActiveRecord::RecordNotFound, with: :record_not_found

      attr_reader :current_user

      private

      def authenticate_user!
        token = request.headers['Authorization']&.split(' ')&.last
        if token
          begin
            user_id = Rails.application.message_verifier('api_session').verify(token)
            @current_user = User.find(user_id)
          rescue ActiveSupport::MessageVerifier::InvalidSignature, ActiveRecord::RecordNotFound
            render json: { error: 'Invalid or expired token' }, status: :unauthorized
          end
        else
          render json: { error: 'Access token missing' }, status: :unauthorized
        end
      end

      def user_not_authorized
        render json: { error: 'You are not authorized to perform this action.' }, status: :forbidden
      end

      def record_not_found(exception)
        render json: { error: "#{exception.model} not found" }, status: :not_found
      end
    end
  end
end
