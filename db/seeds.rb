# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).
#
# Example:
#
#   ["Action", "Comedy", "Drama", "Horror"].each do |genre_name|
#     MovieGenre.find_or_create_by!(name: genre_name)
#   end


# **products テーブル**
# 
# |id|name|price|
# |--|----|-----|
# |1 |商品A|1000 |
# |2 |商品B|2000 |
# 
# **product_options テーブル**
# 
# |id|product_id|feature_category|option_value|
# |--|----------|----------------|------------|
# |1 |1         |color          |RED         |
# |2 |1         |size         |L          |
# |3 |2         |color          |BLUE         |
# |4 |2         |size         |M          |

Product.destroy_all
ProductOption.destroy_all
ProductStock.destroy_all
MaterialStock.destroy_all

product_stock_1 = ProductStock.create([{ stock: 10 }]).first
material_stock_1 = MaterialStock.create([{ stock: 100 }]).first

product1 =  Product.create([
  { name: "完成品商品A", price: 1000 },
]).first

product2 =  Product.create([
  { name: "素材商品B", price: 2000 }
]).first

ProductOption.create!([
  { product_id: product1.id, feature_category: "color", option_value: "RED", value_type: "string" },
  { product_id: product1.id, feature_category: "size", option_value: "L" , value_type: "string" },
  { product_id: product1.id, feature_category: "weight", option_value: "1" , value_type: "integer" },
  { product_id: product1.id, feature_category: "tolerance", option_value: "0.01 ... 0.1" , value_type: "range" },
  { product_id: product1.id, feature_category: "stack", option_value: "GET_PRODUCT_STACK_VALUE:#{product_stock_1.id}" , value_type: "script" },
  { product_id: product2.id, feature_category: "color", option_value: "BLUE" },
  { product_id: product2.id, feature_category: "size", option_value: "M" },
  { product_id: product2.id, feature_category: "weight", option_value: "200" , value_type: "integer" },
  { product_id: product2.id, feature_category: "serial", option_value: "1,'0002',0003,\"0004\"" , value_type: "list" },
  { product_id: product2.id, feature_category: "stack", option_value: "GET_MATERIAL_STACK_VALUE:#{material_stock_1.id}" , value_type: "script" }
])
