#- products
#  - id
#  - name
#  - price
#  - created_at
#  - updated_at
class AddProducts < ActiveRecord::Migration[8.0]
  def change
    create_table :products do |t|
      t.string :name, null: false
      t.decimal :price, precision: 10, scale: 2, null: false

      t.timestamps
    end
  end
end
