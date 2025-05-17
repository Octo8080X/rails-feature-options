# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_05_16_163651) do
  create_table "material_stocks", force: :cascade do |t|
    t.integer "stock", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "product_options", force: :cascade do |t|
    t.integer "product_id", null: false
    t.string "feature_category", null: false
    t.string "option_value", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "value_type", default: "string", null: false
    t.index ["product_id", "feature_category"], name: "index_product_options_on_product_id_and_feature_category", unique: true
    t.index ["product_id"], name: "index_product_options_on_product_id"
  end

  create_table "product_stocks", force: :cascade do |t|
    t.integer "stock", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "products", force: :cascade do |t|
    t.string "name", null: false
    t.decimal "price", precision: 10, scale: 2, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  add_foreign_key "product_options", "products"
end
