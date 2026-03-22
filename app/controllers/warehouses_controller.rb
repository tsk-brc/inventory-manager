class WarehousesController < ApplicationController
  before_action :set_warehouse, only: %i[show edit update destroy]

  def index
    @warehouses = Warehouse.ordered.page(params[:page])
  end

  def show
    @inventories = @warehouse.inventories.includes(:product)
    @recent_movements = @warehouse.stock_movements.recent.includes(:product, :user).limit(10)
  end

  def new
    @warehouse = Warehouse.new
  end

  def edit; end

  def create
    @warehouse = Warehouse.new(warehouse_params)

    if @warehouse.save
      redirect_to @warehouse, notice: 'Warehouse was successfully created.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @warehouse.update(warehouse_params)
      redirect_to @warehouse, notice: 'Warehouse was successfully updated.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @warehouse.destroy
      redirect_to warehouses_url, notice: 'Warehouse was successfully deleted.', status: :see_other
    else
      redirect_to @warehouse, alert: @warehouse.errors.full_messages.join(', ')
    end
  end

  private

  def set_warehouse
    @warehouse = Warehouse.find(params[:id])
  end

  def warehouse_params
    params.expect(warehouse: %i[name address])
  end
end
