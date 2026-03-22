require 'rails_helper'

RSpec.describe 'Dashboard' do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET /' do
    it 'returns success' do
      get root_path
      expect(response).to have_http_status(:ok)
    end

    it 'displays low stock products' do
      low = create(:product, name: 'Low Item', minimum_quantity: 20)
      create(:inventory, product: low, quantity: 5)

      get root_path
      expect(response.body).to include('Low Item')
    end

    it 'displays recent stock movements' do
      movement = create(:stock_movement, reason: 'Test shipment')

      get root_path
      expect(response.body).to include(movement.product.name)
    end
  end

  context 'when not authenticated' do
    before { sign_out user }

    it 'redirects to sign in' do
      get root_path
      expect(response).to redirect_to(new_user_session_path)
    end
  end
end
