require 'rails_helper'

RSpec.describe Inventory do
  describe 'associations' do
    it { is_expected.to belong_to(:product) }
    it { is_expected.to belong_to(:warehouse) }
  end

  describe 'validations' do
    subject { build(:inventory) }

    it {
      expect(subject).to validate_numericality_of(:quantity)
        .only_integer.is_greater_than_or_equal_to(0)
    }

    it { is_expected.to validate_uniqueness_of(:product_id).scoped_to(:warehouse_id) }
  end

  describe '.low_stock' do
    it 'returns inventories at or below product minimum quantity' do
      product = create(:product, minimum_quantity: 20)
      low = create(:inventory, product: product, quantity: 10)
      create(:inventory, product: product, quantity: 50)

      expect(described_class.low_stock).to contain_exactly(low)
    end
  end
end
