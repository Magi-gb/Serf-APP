class ApplicationController < ActionController::Base
  include Authorizable

  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :authenticate_user!

  layout :set_layout

  private

  def after_sign_in_path_for(resource)
    resource.admin? ? users_path : root_path
  end

  def set_layout
    devise_controller? ? "login" : "application"
  end
end
