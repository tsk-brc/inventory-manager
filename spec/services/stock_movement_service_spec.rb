require 'rails_helper'

RSpec.describe StockMovementService do
  let(:user) { create(:user) }
  let(:product) { create(:product) }
  let(:warehouse) { create(:warehouse) }

  describe '#call' do
    context 'with inbound movement' do
      let(:params) do
        { product_id: product.id, warehouse_id: warehouse.id, quantity: 50, operation_type: 'inbound',
          reason: 'Initial stock' }
      end

      it 'creates a stock movement and inventory record' do
        service = described_class.new(params: params, user: user)

        expect { service.call }.to change(StockMovement, :count).by(1)
                                                                .and change(Inventory, :count).by(1)

        inventory = Inventory.find_by(product: product, warehouse: warehouse)
        expect(inventory.quantity).to eq(50)
      end

      it 'increments existing inventory' do
        create(:inventory, product: product, warehouse: warehouse, quantity: 30)
        service = described_class.new(params: params, user: user)

        expect { service.call }.not_to change(Inventory, :count)

        inventory = Inventory.find_by(product: product, warehouse: warehouse)
        expect(inventory.quantity).to eq(80)
      end
    end

    context 'with outbound movement' do
      let!(:inventory) { create(:inventory, product: product, warehouse: warehouse, quantity: 100) }
      let(:params) do
        { product_id: product.id, warehouse_id: warehouse.id, quantity: 30, operation_type: 'outbound',
          reason: 'Order fulfillment' }
      end

      it 'creates a movement and decrements inventory' do
        service = described_class.new(params: params, user: user)
        expect(service.call).to be true

        expect(inventory.reload.quantity).to eq(70)
      end

      it 'fails when stock is insufficient' do
        params[:quantity] = 200
        service = described_class.new(params: params, user: user)

        expect(service.call).to be false
        expect(service.error).to include('在庫が不足しています')
        expect(inventory.reload.quantity).to eq(100)
      end
    end

    context 'with invalid params' do
      it 'returns false and sets error' do
        service = described_class.new(params: { quantity: -1 }, user: user)

        expect(service.call).to be false
        expect(service.error).to be_present
      end
    end
  end
end
