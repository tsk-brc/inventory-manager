require 'rails_helper'

RSpec.describe 'StockMovements' do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET /stock_movements' do
    it 'returns success' do
      get stock_movements_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /stock_movements/:id' do
    it 'returns success' do
      movement = create(:stock_movement)
      get stock_movement_path(movement)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /stock_movements/new' do
    it 'returns success' do
      get new_stock_movement_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /stock_movements' do
    let(:product) { create(:product) }
    let(:warehouse) { create(:warehouse) }

    it 'creates an inbound movement and updates inventory' do
      params = {
        stock_movement: {
          product_id: product.id,
          warehouse_id: warehouse.id,
          quantity: 50,
          operation_type: 'inbound',
          reason: 'Restock'
        }
      }

      expect { post stock_movements_path, params: params }.to change(StockMovement, :count).by(1)
      expect(response).to redirect_to(StockMovement.last)

      inventory = Inventory.find_by(product: product, warehouse: warehouse)
      expect(inventory.quantity).to eq(50)
    end

    it 'renders new on insufficient stock for outbound' do
      create(:inventory, product: product, warehouse: warehouse, quantity: 5)

      params = {
        stock_movement: {
          product_id: product.id,
          warehouse_id: warehouse.id,
          quantity: 100,
          operation_type: 'outbound',
          reason: 'Order'
        }
      }

      post stock_movements_path, params: params
      expect(response).to have_http_status(:unprocessable_content)
    end
  end
end
