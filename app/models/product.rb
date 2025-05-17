class Product < ApplicationRecord
  OPTION_CATEGORIES = %w[color size weight tolerance serial stack].freeze
  OPTION_SCRIPT_METHODS = {
    GET_PRODUCT_STACK_VALUE: Proc.new { |id| ProductStock.find(id).stock },
    GET_MATERIAL_STACK_VALUE: Proc.new { |id| MaterialStock.find(id).stock },
  }

  include FeatureOption

  has_many :product_options, dependent: :destroy

  validates :name, presence: true
  validates :price, presence: true, numericality: { greater_than_or_equal_to: 0 }
end