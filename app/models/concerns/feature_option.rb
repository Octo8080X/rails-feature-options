module FeatureOption
  extend ActiveSupport::Concern
  
  included do
    # 読み込まれた際にOPTION_CATEGORIESの定義が無ければエラーにする
    if defined?(base_class.name.constantize::OPTION_CATEGORIES) != "constant"
      raise ArgumentError, "OPTION_CATEGORIES is not defined"
    end

    scope :with_options, -> (categories = nil) {
      ## feature options を使用するとき、親のテーブルと小テーブルの名称は以下のようにする。
      ## 親テーブル名 = products
      ## 子テーブル名 = [親テーブル名単数形]_options
      model_name = self.name.downcase.singularize
      table_name = self.table_name

      joins("#{model_name}_options".to_sym)
               .select("#{table_name}.*, #{get_option_query(model_name, categories)}")
               .group("#{table_name}.id") 
    }
  end
  
  class_methods do
    def get_option_query(model_name, categories)
      target_categories = categories || base_class::OPTION_CATEGORIES
      table_name = "#{model_name}_options"

      target_categories.map do |category|
        "MAX(CASE WHEN #{table_name}.feature_category = '#{category}' THEN #{table_name}.option_value END) AS #{get_option_value_key(model_name, category)},
         MAX(CASE WHEN #{table_name}.feature_category = '#{category}' THEN #{table_name}.value_type END) AS #{get_option_type_key(model_name, category)}"
      end.join(",")
    end

    def get_option_value_key(model_name, method_name)
      "#{model_name}_option_value_#{method_name}"
    end
  
    def get_option_type_key(model_name, method_name)
      "#{model_name}_option_type_#{method_name}"
    end
  end

  # モデルに定義が無い場合に発火するメソッド
  def method_missing(method_name, *args, &block)
    super unless is_feature_option_value?(method_name)

    get_option_value(method_name)
  end

  private

  def get_option_value_key(model_name, method_name)
    "#{model_name}_option_value_#{method_name}"
  end

  def get_option_type_key(model_name, method_name)
    "#{model_name}_option_type_#{method_name}"
  end

  def is_feature_option_value?(method_name)
    attributes_hash = self.attributes
    model_name = self.class.name.downcase.singularize

    attributes_hash.dig(self.get_option_value_key(model_name, method_name)).presence &&
    attributes_hash.dig(self.get_option_type_key(model_name, method_name)).presence &&
    ["script", "list", "range", "string", "integer"].include?(attributes_hash.dig(get_option_type_key(model_name, method_name)))
  end

  def get_option_value(method_name)
    attributes_hash = self.attributes
    model_name = self.class.name.downcase.singularize
    org_value = attributes_hash.dig(self.get_option_value_key(model_name, method_name))
    value_type = attributes_hash.dig(self.get_option_type_key(model_name, method_name)).presence

    return org_value if value_type == "string"  
    return org_value.to_i if value_type == "integer"
    return get_option_range_value(method_name, org_value) if value_type == "range"
    return get_option_list_value(method_name, org_value) if value_type == "list"
    return get_option_script_value(method_name, org_value) if value_type == "script"
  end

  def get_option_range_value(method_name, org_value)
    mode = 
      if org_value.include?("...")
        "..."
      elsif org_value.include?("..")
        ".."
      else
        "ERROR"
      end
  
    raise "FeatureOption::NotRangeFormat", "#{method_name} is not range format" if mode == "ERROR"
  
    range_start, range_end = org_value.split(mode).map(&:strip)
    range_start = range_start.to_f if range_start =~ /\A\d+(\.\d+)?\z/
    range_end = range_end.to_f if range_end =~ /\A\d+(\.\d+)?\z/
    
    return Range.new(range_start, range_end, true) if mode == "..."
    Range.new(range_start, range_end)
  end

  def get_option_list_value(method_name, org_value)
    tmp = org_value.split(",").map(&:strip)
    raise "FeatureOption::NotListFormat", "#{method_name} is not list format, org_value: #{org_value}, #{e.message}" if tmp.empty?

    string_to_value(tmp)
  end

  def string_to_value(string_list)
    string_list.map do |v|
      if v =~ /\A\d+(\.\d+)?\z/
        v.to_f
      elsif v =~ /\A\d+\z/
        v.to_i
      else
        v.tr("'", "")
      end
    end
  end

  def get_option_script_value(method_name, org_value)
    script_name, args = org_value.split(":").map(&:strip)
    if args.present?
      args = args.split(",").map(&:strip)
      args = string_to_value(args)
    end
  
    raise "FeatureOption::NotDefinedOptionScriptMethods" unless self.class.const_defined?(:OPTION_SCRIPT_METHODS)
    raise "FeatureOption::NotAllowMethod" unless allow_method_names.include?(script_name)

    self.class::OPTION_SCRIPT_METHODS[script_name.to_sym].call(*args)
  end  

  def allow_method_names
    self.class::OPTION_SCRIPT_METHODS.keys.map(&:to_s)
  end
end
