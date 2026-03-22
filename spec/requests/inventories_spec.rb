require 'rails_helper'

RSpec.describe 'Inventories' do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET /inventories' do
    it 'returns success' do
      create(:inventory)
      get inventories_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /inventories/:id' do
    it 'returns success' do
      inventory = create(:inventory)
      get inventory_path(inventory)
      expect(response).to have_http_status(:ok)
    end
  end
end
