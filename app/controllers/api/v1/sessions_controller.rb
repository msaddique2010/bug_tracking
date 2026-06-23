module Api
  module V1
    class SessionsController < ApiController
      skip_before_action :authenticate_user!, only: :create

      # POST /api/v1/login
      def create
        user = User.find_by(email: params[:email])
        if user&.valid_password?(params[:password])
          # Generate a secure signed token
          token = Rails.application.message_verifier('api_session').generate(user.id, expires_in: 24.hours)
          render json: {
            token: token,
            user: {
              id: user.id,
              name: user.name,
              email: user.email,
              user_type: user.user_type
            }
          }, status: :ok
        else
          render json: { error: 'Invalid email or password' }, status: :unauthorized
        end
      end

      # DELETE /api/v1/logout
      def destroy
        # Since we use stateless tokens, client side simply discards the token.
        # But we can respond with success.
        render json: { message: 'Logged out successfully' }, status: :ok
      end
    end
  end
end
