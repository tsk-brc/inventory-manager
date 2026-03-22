class StockMovement < ApplicationRecord
  belongs_to :product
  belongs_to :warehouse
  belongs_to :user

  enum :operation_type, { inbound: 0, outbound: 1 }

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }
  validates :operation_type, presence: true

  scope :recent, -> { order(created_at: :desc) }
end
