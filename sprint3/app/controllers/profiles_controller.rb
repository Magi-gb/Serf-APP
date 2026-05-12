class ProfilesController < ApplicationController
  def show
  end

  def edit
  end

  def update
    unless current_user.valid_password?(params[:profile][:current_password])
      current_user.errors.add(:base, t("profile.update.invalid_current_password"))
      return render :edit, status: :unprocessable_entity
    end

    if current_user.update(password_params)
      bypass_sign_in(current_user)
      redirect_to profile_path, notice: t("profile.update.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:profile).permit(:password, :password_confirmation)
  end
end
