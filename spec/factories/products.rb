FactoryBot.define do
  factory :product do
    sequence(:name) { |n| "Product #{n}" }
    sequence(:sku) { |n| "SKU-#{n.to_s.rjust(4, '0')}" }
    description { 'A sample product' }
    minimum_quantity { 10 }
  end
end
