class InventoriesController < ApplicationController
  def index
    @inventories = Inventory.includes(:product, :warehouse)
                            .joins(:product)
                            .order('products.name')
                            .page(params[:page])
  end

  def show
    @inventory = Inventory.includes(:product, :warehouse).find(params[:id])
  end
end
