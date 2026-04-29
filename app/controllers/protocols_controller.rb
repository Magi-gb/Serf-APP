class ProtocolsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!, only: %i[edit update]
  before_action :set_protocol, only: %i[show edit update]

  def index
    @protocols = Protocol.all
  end

  def show
  end

  # def new
  #   Creació de protocols no inclosa en la iteració actual per requeriments
  # end

  # def create
  #   Creació de protocols no inclosa en la iteració actual per requeriments
  # end

  def edit
  end

  def update
    if @protocol.update(protocol_params)
      redirect_to @protocol, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  # def destroy
  #   Eliminació de protocols no inclosa en la iteració actual per requeriments
  # end

  private

  def set_protocol
    @protocol = Protocol.find(params[:id])
  end

  def protocol_params
    params.require(:protocol).permit(:name, :description)
  end
end
