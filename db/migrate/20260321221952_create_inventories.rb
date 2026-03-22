class CreateInventories < ActiveRecord::Migration[8.1]
  def change
    create_table :inventories do |t|
      t.references :product, null: false, foreign_key: true
      t.references :warehouse, null: false, foreign_key: true
      t.integer :quantity, null: false, default: 0

      t.timestamps
    end

    add_index :inventories, %i[product_id warehouse_id], unique: true
    add_check_constraint :inventories, 'quantity >= 0', name: 'inventories_quantity_non_negative'
  end
end
