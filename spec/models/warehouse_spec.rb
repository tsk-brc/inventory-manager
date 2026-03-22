require 'rails_helper'

RSpec.describe Warehouse do
  describe 'associations' do
    it { is_expected.to have_many(:inventories).dependent(:destroy) }
    it { is_expected.to have_many(:products).through(:inventories) }
    it { is_expected.to have_many(:stock_movements).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    subject { build(:warehouse) }

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_uniqueness_of(:name) }
  end
end
