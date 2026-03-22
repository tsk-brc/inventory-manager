class StockMovementsController < ApplicationController
  def index
    @stock_movements = StockMovement.recent
                                    .includes(:product, :warehouse, :user)
                                    .page(params[:page])
  end

  def show
    @stock_movement = StockMovement.includes(:product, :warehouse, :user).find(params[:id])
  end

  def new
    @stock_movement = StockMovement.new
  end

  def create
    service = StockMovementService.new(params: stock_movement_params, user: current_user)

    if service.call
      redirect_to service.movement, notice: 'Stock movement was successfully recorded.'
    else
      @stock_movement = service.movement || StockMovement.new(stock_movement_params)
      flash.now[:alert] = service.error
      render :new, status: :unprocessable_content
    end
  end

  private

  def stock_movement_params
    params.expect(stock_movement: %i[product_id warehouse_id quantity operation_type reason])
  end
end
