FactoryBot.define do
  factory :stock_movement do
    product
    warehouse
    user
    quantity { 10 }
    operation_type { :inbound }
    reason { 'Regular shipment' }
  end
end
