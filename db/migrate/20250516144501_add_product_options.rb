#- Product_options
#  - id
#  - product_id
#  - feature_category
#  - option_value
#  - created_at
#  - updated_at
class AddProductOptions < ActiveRecord::Migration[8.0]
  def change
    create_table :product_options do |t|
      t.references :product, null: false, foreign_key: true
      t.string :feature_category, null: false
      t.string :option_value, null: false

      t.timestamps
    end

    add_index :product_options, [:product_id, :feature_category], unique: true
  end
end
