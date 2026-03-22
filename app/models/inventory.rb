class Inventory < ApplicationRecord
  belongs_to :product
  belongs_to :warehouse

  validates :quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :product_id, uniqueness: { scope: :warehouse_id }

  scope :low_stock, -> { joins(:product).where('inventories.quantity <= products.minimum_quantity') }
end
