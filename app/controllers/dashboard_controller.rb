class DashboardController < ApplicationController
  def index
    @low_stock_products = Product.low_stock.ordered.limit(10)
    @recent_movements = StockMovement.recent.includes(:product, :warehouse, :user).limit(10)
  end
end
