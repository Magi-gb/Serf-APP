class ProtocolsController < ApplicationController
  before_action :require_admin!, only: %i[edit update]
  before_action :set_protocol, only: %i[show edit update]

  # GET /protocols
  def index
    @protocols = Protocol.all
    @protocols = @protocols.where("name LIKE ?", "%#{params[:query]}%") if params[:query].present?
  end

  # GET /protocols/1
  def show
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

  # Protocol creation and deletion actions belong to their own tasks.

  private

  def set_protocol
    @protocol = Protocol.find(params[:id])
  end

  def protocol_params
    params.require(:protocol).permit(:name, :description, :bg_color, :icon_svg)
  end
end
