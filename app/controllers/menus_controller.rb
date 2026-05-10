class MenusController < ApplicationController
  before_action :require_kitchen_manager_or_above!, except: [ :index, :show ]
  before_action :set_menu, only: [ :destroy, :edit, :update, :show ]

  def index
    @menus = Menu.search(params[:search]).order(name: :asc)
  end

  def show
    @menu
  end

  def new
    @menu = Menu.new
    load_available_plats
  end

  def create
    @menu = Menu.new(menu_params)

    if @menu.save
      redirect_to menus_path, notice: t("menus.messages.created_success")
    else
      load_available_plats
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    load_available_plats
  end

  def update
    if @menu.update(menu_params)
      redirect_to menus_path, notice: t("menus.messages.updated_success")
    else
      load_available_plats
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @menu.destroy
    redirect_to menus_path, notice: t("menus.messages.destroyed_success"), status: :see_other
  end

  private

  def set_menu
    @menu = Menu.find(params[:id])
  end

  def menu_params
    params.require(:menu).permit(:name, plat_ids: [])
  end

  def load_available_plats
    @plats_by_type = Plat.all.group_by(&:tipusPlat)
  end
end
