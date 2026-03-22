class CreateProducts < ActiveRecord::Migration[8.1]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.string :sku, null: false
      t.text :description
      t.integer :minimum_quantity, null: false, default: 0

      t.timestamps
    end

    add_index :products, :sku, unique: true
  end
end
