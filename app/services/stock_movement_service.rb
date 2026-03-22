class StockMovementService
  attr_reader :movement, :error

  def initialize(params:, user:)
    @params = params
    @user = user
  end

  def call
    ActiveRecord::Base.transaction do
      @movement = build_movement
      inventory = find_or_initialize_inventory

      adjust_quantity!(inventory)

      movement.save!
      inventory.save!
    end

    true
  rescue ActiveRecord::RecordInvalid => e
    @error = e.record.errors.full_messages.join(', ')
    false
  rescue InsufficientStockError => e
    @error = e.message
    false
  end

  private

  def build_movement
    StockMovement.new(@params.merge(user: @user))
  end

  def find_or_initialize_inventory
    Inventory.find_or_initialize_by(
      product_id: movement.product_id,
      warehouse_id: movement.warehouse_id
    )
  end

  def adjust_quantity!(inventory)
    case movement.operation_type
    when 'inbound'
      inventory.quantity += movement.quantity
    when 'outbound'
      new_quantity = inventory.quantity - movement.quantity
      if new_quantity.negative?
        raise InsufficientStockError,
              "在庫が不足しています（現在: #{inventory.quantity}、出庫: #{movement.quantity}）"
      end

      inventory.quantity = new_quantity
    end
  end

  class InsufficientStockError < StandardError; end
end
