class ProductOption < ApplicationRecord
  belongs_to :product

  validates :feature_category, presence: true
  validates :option_value, presence: true
  validates :product_id, presence: true

  # Ensure that the combination of product_id and feature_category is unique
  validates :product_id, uniqueness: { scope: :feature_category }
end