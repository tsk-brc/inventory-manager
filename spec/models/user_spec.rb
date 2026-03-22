require 'rails_helper'

RSpec.describe User do
  describe 'associations' do
    it { is_expected.to have_many(:stock_movements).dependent(:restrict_with_error) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:email) }
    it { is_expected.to validate_presence_of(:password) }
  end
end
