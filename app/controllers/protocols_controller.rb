class ProtocolsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_kitchen_manager_or_above!, only: %i[index]
  before_action :require_admin!, only: %i[new create edit update destroy]
  before_action :set_protocol, only: %i[show edit update destroy]

  # GET /protocols
  def index
    @protocols = Protocol.search(params[:search])
  end

  # GET /protocols/1
  def show
  end

  # GET /protocols/new
  def new
    @protocol = Protocol.new
  end

  # POST /protocols
  def create
    @protocol = Protocol.new(protocol_params)

    if @protocol.save
      redirect_to protocols_path, notice: I18n.t("protocols.messages.created_success"), status: :see_other
    else
      render :new, status: :unprocessable_entity
    end
  end

  # GET /protocols/1/edit
  def edit
  end

  # PATCH/PUT /protocols/1
  def update
    if @protocol.update(protocol_params)
      redirect_to @protocol, notice: I18n.t("protocols.messages.updated_success"), status: :see_other
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @protocol.destroy
    redirect_to protocols_path, notice: I18n.t("protocols.messages.destroyed_success"), status: :see_other
  end

  private

  def set_protocol
    @protocol = Protocol.find(params[:id])
  end

  def protocol_params
    params.require(:protocol).permit(:name, :description)
  end
end
