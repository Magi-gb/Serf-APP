module Authorizable
  extend ActiveSupport::Concern

  private

  def require_admin!
    deny_access! unless current_user.admin?
  end

  def require_kitchen_manager_or_above!
    deny_access! unless current_user.admin? || current_user.kitchen_manager?
  end

  def deny_access!
    redirect_to root_path, alert: "You are not authorized to access this page."
  end
end
