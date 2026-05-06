class ProtocolsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_kitchen_manager_or_above!, only: %i[index]
  before_action :require_admin!, only: %i[new create edit update destroy]
  before_action :set_protocol, only: %i[show edit update destroy]

  def index
    @protocols = Protocol.all
  end

  def show
  end

  def new
    @protocol = Protocol.new
  end

  def create
    @protocol = Protocol.new(protocol_params)
    if @protocol.save
      redirect_to @protocol, notice: t(".success")
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @protocol.update(protocol_params)
      redirect_to @protocol, notice: t(".success")
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @protocol.destroy!
    redirect_to protocols_path, notice: t(".success"), status: :see_other
  end

  private

  def set_protocol
    @protocol = Protocol.find(params[:id])
  end

  def protocol_params
    params.require(:protocol).permit(:name, :description)
  end
end
