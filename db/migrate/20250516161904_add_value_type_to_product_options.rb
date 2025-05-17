class AddValueTypeToProductOptions < ActiveRecord::Migration[8.0]
  def up
    add_column :product_options, :value_type, :string, null: false, default: 'string' 
  end

  def down
    remove_column :product_options, :value_type
  end
end
