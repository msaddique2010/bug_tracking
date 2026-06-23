class ApplicationController < ActionController::Base
  include Pundit::Authorization
  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  before_action :authenticate_user!

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected
  def user_not_authorized
      redirect_to projects_path, alert: "You are not authorized to perform this action."
  end

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [ :name, :user_type ])
    devise_parameter_sanitizer.permit(:account_update, keys: [ :name, :user_type ])
  end
end
