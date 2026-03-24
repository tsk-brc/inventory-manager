require 'rails_helper'

RSpec.describe Product do
  describe 'associations' do
    it { is_expected.to have_many(:inventories).dependent(:destroy) }
    it { is_expected.to have_many(:warehouses).through(:inventories) }
    it { is_expected.to have_many(:stock_movements).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject { build(:product) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:sku) }
    it { is_expected.to validate_uniqueness_of(:sku) }

    it {
      expect(subject).to validate_numericality_of(:minimum_quantity)
        .only_integer.is_greater_than_or_equal_to(0)
    }
  end

  describe '#total_quantity' do
    it 'returns sum of inventory quantities across warehouses' do
      product = create(:product)
      create(:inventory, product: product, quantity: 50)
      create(:inventory, product: product, quantity: 30)

      expect(product.total_quantity).to eq(80)
    end

    it 'returns 0 when no inventories exist' do
      product = create(:product)
      expect(product.total_quantity).to eq(0)
    end
  end

  describe '#low_stock?' do
    it 'returns true when total quantity is at or below minimum' do
      product = create(:product, minimum_quantity: 10)
      create(:inventory, product: product, quantity: 5)

      expect(product).to be_low_stock
    end

    it 'returns false when total quantity exceeds minimum' do
      product = create(:product, minimum_quantity: 10)
      create(:inventory, product: product, quantity: 50)

      expect(product).not_to be_low_stock
    end
  end

  describe '.low_stock' do
    it 'returns products where total inventory is at or below minimum quantity' do
      low = create(:product, minimum_quantity: 20)
      create(:inventory, product: low, quantity: 10)

      adequate = create(:product, minimum_quantity: 5)
      create(:inventory, product: adequate, quantity: 50)

      expect(described_class.low_stock.where(id: [low.id, adequate.id])).to contain_exactly(low)
    end

    it 'includes products with no inventory' do
      no_stock = create(:product, minimum_quantity: 1)
      expect(described_class.low_stock.where(id: no_stock.id)).to include(no_stock)
    end
  end
end
