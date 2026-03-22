FactoryBot.define do
  factory :warehouse do
    sequence(:name) { |n| "Warehouse #{n}" }
    address { 'Tokyo, Japan' }
  end
end
