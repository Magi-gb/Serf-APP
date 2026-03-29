class RestrictionsController < ApplicationController
  before_action :set_restriction, only: %i[ show edit update destroy ]

  # GET /restrictions or /restrictions.json
  def index
    @restrictions = Restriction.all
  end

  # GET /restrictions/1 or /restrictions/1.json
  def show
  end

  # GET /restrictions/new
  def new
    @restriction = Restriction.new
  end

  # GET /restrictions/1/edit
  def edit
  end

  # POST /restrictions or /restrictions.json
  def create
    @restriction = Restriction.new(restriction_params)

    respond_to do |format|
      if @restriction.save
        format.html { redirect_to @restriction, notice: "Restriction was successfully created." }
        format.json { render :show, status: :created, location: @restriction }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @restriction.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /restrictions/1 or /restrictions/1.json
  def update
    respond_to do |format|
      if @restriction.update(restriction_params)
        format.html { redirect_to @restriction, notice: "Restriction was successfully updated.", status: :see_other }
        format.json { render :show, status: :ok, location: @restriction }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @restriction.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /restrictions/1 or /restrictions/1.json
  def destroy
    @restriction.destroy!

    respond_to do |format|
      format.html { redirect_to restrictions_path, notice: "Restriction was successfully destroyed.", status: :see_other }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_restriction
      @restriction = Restriction.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def restriction_params
      params.require(:restriction).permit(:name, :description, :bg_color)
    end
end
