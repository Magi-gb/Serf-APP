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
  end

  def create
    @menu = Menu.new(menu_params)

    if @menu.save
      redirect_to menus_path, notice: t("menus.messages.created_success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @menu.update(menu_params)
      redirect_to menus_path, notice: t("menus.messages.updated_success")
    else
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
end
