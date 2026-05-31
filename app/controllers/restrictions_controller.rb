class RestrictionsController < ApplicationController
  before_action :require_kitchen_manager_or_above!, except: %i[ index show ]
  before_action :set_restriction, only: %i[ show edit update destroy ]

  # GET /restrictions
  def index
    @restrictions = Restriction.all
  end

  # GET /restrictions/1
  def show
    @ingredients = @restriction.ingredients.order(:name).to_a
  end

  # GET /restrictions/new
  def new
    @restriction = Restriction.new
  end

  # GET /restrictions/1/edit
  def edit
  end

  # POST /restrictions
  def create
    @restriction = Restriction.new(restriction_params)

    if @restriction.save
      redirect_to @restriction, notice: I18n.t("restrictions.messages.created_success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  # PATCH/PUT /restrictions/1
  def update
    if @restriction.update(restriction_params)
      redirect_to @restriction, notice: I18n.t("restrictions.messages.updated_success"), status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /restrictions/1
  def destroy
    @restriction.destroy!

    redirect_to restrictions_path, notice: I18n.t("restrictions.messages.destroyed_success"), status: :see_other
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_restriction
      @restriction = Restriction.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def restriction_params
      params.require(:restriction).permit(:name, :description, :restriction_type, :bg_color, :icon_svg)
    end
end
