class RestriccionsController < ApplicationController
  before_action :set_restriccio, only: [:show, :edit, :update, :destroy]

  def index
    @restriccions = Restriccio.all
  end

  def show
  end

  def new
    @restriccio = Restriccio.new
  end

  def create
    @restriccio = Restriccio.new(restriccio_params)
    if @restriccio.save
      redirect_to @restriccio, notice: "Restricció creada correctament."
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @restriccio.update(restriccio_params)
      redirect_to @restriccio, notice: "Restricció actualitzada correctament."
    else
      render :edit
    end
  end

  def destroy
    @restriccio.destroy
    redirect_to restriccions_path, notice: "Restricció eliminada."
  end

  private

  def set_restriccio
    @restriccio = Restriccio.find(params[:id])
  end

  def restriccio_params
    params.require(:restriccio).permit(:name, :description, ingredient_ids: [])
  end
end
