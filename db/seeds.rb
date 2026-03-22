user = User.find_or_create_by!(email: 'admin@example.com') do |u|
  u.password = 'password'
end

products = [
  { name: 'Wireless Mouse', sku: 'ELEC-0001', description: 'Ergonomic wireless mouse', minimum_quantity: 20 },
  { name: 'USB-C Cable', sku: 'ELEC-0002', description: '1m USB-C to USB-C cable', minimum_quantity: 50 },
  { name: 'Mechanical Keyboard', sku: 'ELEC-0003', description: 'Cherry MX Blue switches', minimum_quantity: 10 },
  { name: 'Monitor Stand', sku: 'FURN-0001', description: 'Adjustable monitor arm', minimum_quantity: 5 },
  { name: 'Desk Lamp', sku: 'FURN-0002', description: 'LED desk lamp with dimmer', minimum_quantity: 15 }
].map { |attrs| Product.find_or_create_by!(sku: attrs[:sku]) { |p| p.assign_attributes(attrs) } }

warehouses = [
  { name: 'Tokyo Main', address: '1-1-1 Marunouchi, Chiyoda-ku, Tokyo' },
  { name: 'Osaka Branch', address: '2-3-4 Umeda, Kita-ku, Osaka' }
].map { |attrs| Warehouse.find_or_create_by!(name: attrs[:name]) { |w| w.assign_attributes(attrs) } }

if StockMovement.none?
  movements = [
    { product: products[0], warehouse: warehouses[0], quantity: 100, operation_type: 'inbound',
      reason: 'Initial stock' },
    { product: products[1], warehouse: warehouses[0], quantity: 200, operation_type: 'inbound',
      reason: 'Initial stock' },
    { product: products[2], warehouse: warehouses[0], quantity: 30, operation_type: 'inbound',
      reason: 'Initial stock' },
    { product: products[3], warehouse: warehouses[1], quantity: 15, operation_type: 'inbound',
      reason: 'Initial stock' },
    { product: products[4], warehouse: warehouses[1], quantity: 40, operation_type: 'inbound',
      reason: 'Initial stock' },
    { product: products[0], warehouse: warehouses[0], quantity: 85, operation_type: 'outbound',
      reason: 'Bulk order' },
    { product: products[1], warehouse: warehouses[0], quantity: 160, operation_type: 'outbound',
      reason: 'Monthly shipment' },
    { product: products[4], warehouse: warehouses[1], quantity: 30, operation_type: 'outbound',
      reason: 'Store transfer' }
  ]

  movements.each do |attrs|
    StockMovementService.new(params: attrs.except(:product, :warehouse).merge(
      product_id: attrs[:product].id,
      warehouse_id: attrs[:warehouse].id
    ), user: user).call
  end
end

Rails.logger.debug do
  "Seed data loaded: #{Product.count} products, #{Warehouse.count} warehouses, #{StockMovement.count} movements"
end
