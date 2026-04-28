class PlatsController < ApplicationController
  before_action :set_plat, only: [:show, :edit, :update, :destroy]

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
      redirect_to @plat, notice: "Plat creat correctament."
    else
      @ingredients = Ingredient.all
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @plat.update(plat_params)
      redirect_to @plat, notice: "Plat actualitzat correctament."
    else
      @ingredients = Ingredient.all
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @plat.destroy
    redirect_to plats_url, notice: "Plat eliminat correctament."
  end

  private

  def set_plat
    @plat = Plat.find(params[:id])
  end

  def plat_params
    params.require(:plat).permit(:name, :description, ingredient_ids: [])
  end
end
