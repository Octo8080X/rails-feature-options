class AddMaterialStock < ActiveRecord::Migration[8.0]
  def change
    create_table :material_stocks do |t|
      t.integer :stock, null: false

      t.timestamps
    end
  end
end
