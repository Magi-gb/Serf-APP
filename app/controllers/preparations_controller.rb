class PreparationsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_kitchen_manager_or_above!, except: %i[ index show ]
  before_action :set_preparation, only: [ :show, :edit, :update ]

  def index
    @preparations = Preparation.search(params[:search]).order(name: :asc)
    if params[:difficulty].present?
      @preparations = @preparations.where(difficulty: params[:difficulty])
    end
  end

  def show
  end

  def new
    @preparation = Preparation.new
    @dishes = Dish.all.order(name: :asc)
  end

  def create
    @preparation = Preparation.new(preparation_params)

    if @preparation.save
      redirect_to @preparation, notice: t("preparations.messages.created_success"), status: :see_other
    else
      @dishes = Dish.all.order(name: :asc)
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @dishes = Dish.all.order(name: :asc)
  end

  def update
    if @preparation.update(preparation_params)
      redirect_to @preparation, notice: t("preparations.messages.updated_success"), status: :see_other
    else
      @dishes = Dish.all.order(name: :asc)
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_preparation
    @preparation = Preparation.find(params[:id])
  end

  def preparation_params
    params.require(:preparation).permit(:name, :description, :time_minutes, :difficulty, :dish_id)
  end
end
