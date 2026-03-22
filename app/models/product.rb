class Product < ApplicationRecord
  has_many :inventories, dependent: :destroy
  has_many :warehouses, through: :inventories
  has_many :stock_movements, dependent: :restrict_with_error

  validates :name, presence: true
  validates :sku, presence: true, uniqueness: true
  validates :minimum_quantity, numericality: { only_integer: true, greater_than_or_equal_to: 0 }

  scope :ordered, -> { order(:name) }

  def total_quantity
    inventories.sum(:quantity)
  end

  def low_stock?
    total_quantity <= minimum_quantity
  end

  def self.low_stock
    left_joins(:inventories)
      .group(:id)
      .having('COALESCE(SUM(inventories.quantity), 0) <= products.minimum_quantity')
  end
end
