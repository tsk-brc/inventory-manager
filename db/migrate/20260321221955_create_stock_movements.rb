class CreateStockMovements < ActiveRecord::Migration[8.1]
  def change
    create_table :stock_movements do |t|
      t.references :product, null: false, foreign_key: true
      t.references :warehouse, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.integer :quantity, null: false
      t.integer :operation_type, null: false
      t.string :reason

      t.timestamps
    end

    add_check_constraint :stock_movements, 'quantity > 0', name: 'stock_movements_quantity_positive'
    add_index :stock_movements, :created_at
  end
end
