class ProductsController < ApplicationController
  before_action :set_product, only: %i[show edit update destroy]

  def index
    @products = Product.ordered.page(params[:page])
  end

  def show
    @inventories = @product.inventories.includes(:warehouse)
    @recent_movements = @product.stock_movements.recent.includes(:warehouse, :user).limit(10)
  end

  def new
    @product = Product.new
  end

  def edit; end

  def create
    @product = Product.new(product_params)

    if @product.save
      redirect_to @product, notice: 'Product was successfully created.'
    else
      render :new, status: :unprocessable_content
    end
  end

  def update
    if @product.update(product_params)
      redirect_to @product, notice: 'Product was successfully updated.'
    else
      render :edit, status: :unprocessable_content
    end
  end

  def destroy
    if @product.destroy
      redirect_to products_url, notice: 'Product was successfully deleted.', status: :see_other
    else
      redirect_to @product, alert: @product.errors.full_messages.join(', ')
    end
  end

  private

  def set_product
    @product = Product.find(params[:id])
  end

  def product_params
    params.expect(product: %i[name sku description minimum_quantity])
  end
end
