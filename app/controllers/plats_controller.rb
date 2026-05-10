class PlatsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_kitchen_manager_or_above!, except: %i[ index show ]
  before_action :set_plat, only: [ :show, :edit, :update, :destroy ]

  def index
    @plats = Plat.all
  end

  def show
  end

  def new
    @plat = Plat.new
    @ingredients = Ingredient.all
  end

  def edit
    @ingredients = Ingredient.all
  end

  def create
    @plat = Plat.new(plat_params)

    if @plat.save
      redirect_to @plat, notice: t("plats.messages.created_success")
    else
      @ingredients = Ingredient.all
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @plat.update(plat_params)
      redirect_to @plat, notice: t("plats.messages.updated_success")
    else
      @ingredients = Ingredient.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @plat.destroy
    redirect_to plats_url, notice: t("plats.messages.destroyed_success")
  end

  private

  def set_plat
    @plat = Plat.find(params[:id])
  end

  def plat_params
    params.require(:plat).permit(:name, :description, :tipusPlat, ingredient_ids: [])
  end
end
