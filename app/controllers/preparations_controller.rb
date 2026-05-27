class PreparationsController < ApplicationController
  before_action :require_kitchen_manager_or_above!, only: %i[destroy]
  before_action :set_preparation, only: %i[show destroy]

  def index
    @preparations = Preparation.all
  end

  def show
  end

  def destroy
    @preparation.destroy!
    redirect_to preparations_path, notice: I18n.t("preparations.messages.destroyed_success"), status: :see_other
  end

  private

  def set_preparation
    @preparation = Preparation.find(params[:id])
  end
end
