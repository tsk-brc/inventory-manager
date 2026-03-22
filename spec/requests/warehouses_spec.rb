require 'rails_helper'

RSpec.describe 'Warehouses' do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET /warehouses' do
    it 'returns success' do
      get warehouses_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /warehouses/:id' do
    it 'returns success' do
      warehouse = create(:warehouse)
      get warehouse_path(warehouse)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /warehouses' do
    it 'creates a warehouse and redirects' do
      expect do
        post warehouses_path, params: { warehouse: attributes_for(:warehouse) }
      end.to change(Warehouse, :count).by(1)
      expect(response).to redirect_to(Warehouse.last)
    end

    it 'renders new on invalid params' do
      post warehouses_path, params: { warehouse: { name: '' } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'PATCH /warehouses/:id' do
    let!(:warehouse) { create(:warehouse) }

    it 'updates and redirects' do
      patch warehouse_path(warehouse), params: { warehouse: { name: 'Updated' } }
      expect(response).to redirect_to(warehouse)
      expect(warehouse.reload.name).to eq('Updated')
    end
  end

  describe 'DELETE /warehouses/:id' do
    let!(:warehouse) { create(:warehouse) }

    it 'deletes and redirects' do
      expect { delete warehouse_path(warehouse) }.to change(Warehouse, :count).by(-1)
      expect(response).to redirect_to(warehouses_url)
    end
  end
end
