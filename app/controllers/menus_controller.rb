class MenusController < ApplicationController
  before_action :require_kitchen_manager_or_above!, except: [ :index, :show, :alternatives ]
  before_action :set_menu, only: [ :destroy, :edit, :update, :show, :alternatives ]

  def index
    @menus = Menu
      .search(params[:search])
      .with_restrictions(params[:include_restrictions])
      .without_restrictions(params[:exclude_restrictions])
      .order(name: :asc)
    @restrictions = Restriction.order(:name)
  end

  def show
    @coverage = MenuCoverage.new(@menu).call
  end

  def new
    @menu = Menu.new
    load_available_dishes
  end

  def create
    @menu = Menu.new(menu_params)

    if @menu.save
      redirect_to menus_path, notice: t("menus.messages.created_success")
    else
      load_available_dishes
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_available_dishes
  end

  def update
    if @menu.update(menu_params)
      redirect_to menus_path, notice: t("menus.messages.updated_success")
    else
      load_available_dishes
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @menu.destroy
    redirect_to menus_path, notice: t("menus.messages.destroyed_success"), status: :see_other
  end

  def alternatives
    @dish = Dish.find(params[:dish_id])
    excluded_restriction_ids = params[:excluded_restrictions].presence&.split(",")&.map(&:to_i) || []
    restrictions_to_exclude = Restriction.where(id: excluded_restriction_ids)
    @alternatives = @dish.similar(restrictions_to_exclude)
    render partial: "menus/alternatives_list", locals: { alternatives: @alternatives, dish: @dish }
  end

  private

  def set_menu
    @menu = Menu.find(params[:id])
  end

  def menu_params
    params.require(:menu).permit(:name, dish_ids: [])
  end

  def load_available_dishes
    @dishes = Dish.order(:dish_type, :name)
  end
end
