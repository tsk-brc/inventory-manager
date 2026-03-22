require 'rails_helper'

RSpec.describe 'Products' do
  let(:user) { create(:user) }

  before { sign_in user }

  describe 'GET /products' do
    it 'returns success' do
      get products_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /products/:id' do
    it 'returns success' do
      product = create(:product)
      get product_path(product)
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'GET /products/new' do
    it 'returns success' do
      get new_product_path
      expect(response).to have_http_status(:ok)
    end
  end

  describe 'POST /products' do
    let(:valid_params) { { product: attributes_for(:product) } }

    it 'creates a product and redirects' do
      expect { post products_path, params: valid_params }.to change(Product, :count).by(1)
      expect(response).to redirect_to(Product.last)
    end

    it 'renders new on invalid params' do
      post products_path, params: { product: { name: '' } }
      expect(response).to have_http_status(:unprocessable_content)
    end
  end

  describe 'PATCH /products/:id' do
    let!(:product) { create(:product) }

    it 'updates and redirects' do
      patch product_path(product), params: { product: { name: 'Updated' } }
      expect(response).to redirect_to(product)
      expect(product.reload.name).to eq('Updated')
    end
  end

  describe 'DELETE /products/:id' do
    let!(:product) { create(:product) }

    it 'deletes and redirects' do
      expect { delete product_path(product) }.to change(Product, :count).by(-1)
      expect(response).to redirect_to(products_url)
    end
  end
end
