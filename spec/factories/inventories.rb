FactoryBot.define do
  factory :inventory do
    product
    warehouse
    quantity { 100 }
  end
end
