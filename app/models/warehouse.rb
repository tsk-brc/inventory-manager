class Warehouse < ApplicationRecord
  has_many :inventories, dependent: :destroy
  has_many :products, through: :inventories
  has_many :stock_movements, dependent: :restrict_with_error

  validates :name, presence: true, uniqueness: true

  scope :ordered, -> { order(:name) }
end
