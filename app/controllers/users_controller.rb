class UsersController < ApplicationController
  before_action :require_admin!
  before_action :set_user, only: [ :show, :edit, :update, :destroy ]

  def index
    @users = User.search(params[:search])
  end

  def show
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      redirect_to users_path, notice: t("users.create.success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    params_to_use = user_params
    params_to_use = params_to_use.except(:password, :password_confirmation) if params_to_use[:password].blank?

    if @user.update(params_to_use)
      redirect_to users_path, notice: t("users.update.success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @user == current_user
      redirect_to users_path, alert: t("users.destroy.cannot_delete_self")
    else
      @user.destroy
      redirect_to users_path, notice: t("users.destroy.success")
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:username, :role, :password, :password_confirmation)
  end
end
