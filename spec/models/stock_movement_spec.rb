require 'rails_helper'

RSpec.describe StockMovement do
  describe 'associations' do
    it { is_expected.to belong_to(:product) }
    it { is_expected.to belong_to(:warehouse) }
    it { is_expected.to belong_to(:user) }
  end

  describe 'validations' do
    it { is_expected.to validate_numericality_of(:quantity).only_integer.is_greater_than(0) }
  end

  describe 'enums' do
    it { is_expected.to define_enum_for(:operation_type).with_values(inbound: 0, outbound: 1) }
  end

  describe '.recent' do
    it 'returns movements in reverse chronological order' do
      old = create(:stock_movement, created_at: 1.day.ago)
      recent = create(:stock_movement, created_at: Time.current)

      expect(described_class.recent).to eq([recent, old])
    end
  end
end
